//
//  KYCFormViewModel.swift
//  FormBuilderExpress
//
//  Created by Manas Pradhan on 09/07/25.
//

import Combine
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - Form Validation Constants
struct FormValidationConstants {
    static let standardFieldMaxLength = 48
    static let sanitizedFieldMaxLength = 500 // For security sanitization buffer overflow protection
    static let minimumAge = 18 // Minimum age requirement for both member and nominee
}



final class KYCFormViewModel: ObservableObject {
    private let db = Firestore.firestore()
    private var autoSaveTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published Form Data
    @Published var member = Person()
    @Published var memberAddress = Address()
    @Published var nominee = Person()
    @Published var nomineeAddress = Address()
    @Published var account = Account()
    @Published var digitalSignature = DigitalSignature()
    
    // MARK: - Form State
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentStep: DataViewStage = .memberInfo
    @Published var lastAutoSaved: Date?
    
    // MARK: - Validation State
    @Published var isMemberInfoValid = false
    @Published var isMemberAddressValid = false
    @Published var isNomineeInfoValid = false
    @Published var isNomineeAddressValid = false
    @Published var isAccountValid = false
    @Published var isSignatureValid = false
    
    init() {
        setupValidation()
        setupAutoSave()
        loadDraftData()
    }
    
    deinit {
        autoSaveTimer?.invalidate()
    }
    
    // MARK: - Validation Setup
    private func setupValidation() {
        // Member info validation
        $member
            .map { [weak self] member in
                guard let self = self else { return false }
                
                let firstNameValid = member.name.first.isValidName
                let lastNameValid = member.name.last.isValidName
                let middleNameValid = (member.name.middle.isEmpty || member.name.middle.isValidName)
                let emailValid = member.email.isValidEmail
                let phoneValid = member.phone.isValidPhoneNumber
                let ageValid = self.isValidAge(member.birthDate)
                
                // Debug logging
                print("🔍 Member Info Validation:")
                print("  First Name (\(member.name.first)): \(firstNameValid)")
                print("  Last Name (\(member.name.last)): \(lastNameValid)")
                print("  Middle Name (\(member.name.middle)): \(middleNameValid)")
                print("  Email (\(member.email)): \(emailValid)")
                print("  Phone (\(member.phone)): \(phoneValid)")
                print("  Age (\(self.getAge(from: member.birthDate))): \(ageValid)")
                
                let isValid = firstNameValid && lastNameValid && middleNameValid && emailValid && phoneValid && ageValid
                print("  Overall Valid: \(isValid)")
                
                return isValid
            }
            .assign(to: &$isMemberInfoValid)
        
        // Member address validation
        $memberAddress
            .map { address in
                address.addressLine1.isValidAddress &&
                (address.addressLine2.isEmpty || address.addressLine2.isValidAddress) &&
                address.city.isValidCity &&
                address.state.isValidState &&
                address.zipCode.isValidZipCode
            }
            .assign(to: &$isMemberAddressValid)
        
        // Nominee info validation
        $nominee
            .map { [weak self] nominee in
                guard let self = self else { return false }
                return nominee.name.first.isValidName &&
                nominee.name.last.isValidName &&
                (nominee.name.middle.isEmpty || nominee.name.middle.isValidName) &&
                nominee.email.isValidEmail &&
                nominee.phone.isValidPhoneNumber &&
                self.isValidAge(nominee.birthDate)
            }
            .assign(to: &$isNomineeInfoValid)
        
        // Nominee address validation
        $nomineeAddress
            .map { address in
                address.addressLine1.isValidAddress &&
                (address.addressLine2.isEmpty || address.addressLine2.isValidAddress) &&
                address.city.isValidCity &&
                address.state.isValidState &&
                address.zipCode.isValidZipCode
            }
            .assign(to: &$isNomineeAddressValid)
        
        // Account validation
        $account
            .map { account in
                account.accountHolderName.isValidAccountHolderName &&
                account.accountNumber.isValidAccountNumber &&
                account.routingNumber.isValidRoutingNumber &&
                account.bankName.isValidBankName &&
                account.accountNumber == account.confirmAccountNumber
            }
            .assign(to: &$isAccountValid)
    }
    
    // MARK: - Navigation Methods
    func canProceedToNext() -> Bool {
        let canProceed: Bool
        switch currentStep {
        case .memberInfo: 
            canProceed = isMemberInfoValid
            print("🚀 canProceedToNext - MemberInfo: \(canProceed)")
        case .memberAddress: 
            canProceed = isMemberAddressValid
            print("🚀 canProceedToNext - MemberAddress: \(canProceed)")
        case .nomineeInfo: 
            canProceed = isNomineeInfoValid
            print("🚀 canProceedToNext - NomineeInfo: \(canProceed)")
        case .nomineeAddress: 
            canProceed = isNomineeAddressValid
            print("🚀 canProceedToNext - NomineeAddress: \(canProceed)")
        case .memberBankDetails: 
            canProceed = isAccountValid
            print("🚀 canProceedToNext - BankDetails: \(canProceed)")
        case .summary: 
            canProceed = true
            print("🚀 canProceedToNext - Summary: \(canProceed)")
        }
        return canProceed
    }
    
    func submitForm() async {
        isLoading = true
        errorMessage = nil
        
        // Security validation
        let securityCheck = FormSecurityValidator.validateFormSubmission()
        guard securityCheck.isValid else {
            errorMessage = securityCheck.errorMessage
            isLoading = false
            return
        }
        
        do {
            // Sanitize all form data before submission
            let sanitizedMember = FormSecurityValidator.sanitizePersonData(member)
            let sanitizedMemberAddress = FormSecurityValidator.sanitizeAddressData(memberAddress)
            let sanitizedNominee = FormSecurityValidator.sanitizePersonData(nominee)
            let sanitizedNomineeAddress = FormSecurityValidator.sanitizeAddressData(nomineeAddress)
            let sanitizedAccount = FormSecurityValidator.sanitizeAccountData(account)
            
            // Update member with sanitized address
            var memberToSubmit = sanitizedMember
            memberToSubmit.address = sanitizedMemberAddress
            
            // Update nominee with sanitized address
            var nomineeToSubmit = sanitizedNominee
            nomineeToSubmit.address = sanitizedNomineeAddress
            
            // Add user ID and timestamp for audit trail
            guard let userId = Auth.auth().currentUser?.uid else {
                errorMessage = "User authentication required"
                isLoading = false
                return
            }
            
            // Save to Firestore with security measures
            try await saveSecurelyToFirestore(
                member: memberToSubmit,
                nominee: nomineeToSubmit,
                account: sanitizedAccount,
                userId: userId
            )
            
        } catch {
            errorMessage = "Failed to submit form: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func saveSecurelyToFirestore(member: Person, nominee: Person, account: Account, userId: String) async throws {
        let batch = db.batch()
        let timestamp = Date()
        
        // Find User ID
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User authentication required"
            isLoading = false
            return
        }

        // Create audit trail entry
        let auditData: [String: Any] = [
            "userId": userId,
            "action": "kyc_form_submission",
            "timestamp": timestamp,
            "deviceInfo": await getDeviceInfo()
        ]
        
        let auditRef = db.collection("users").document(userId).collection("audit_logs").document()
        batch.setData(auditData, forDocument: auditRef)
        
        // Save member data
        let memberRef = db.collection("users").document(userId).collection("members").document()
        let memberData = try Firestore.Encoder().encode(member)
        var memberDataWithMeta = memberData
        memberDataWithMeta["userId"] = userId
        memberDataWithMeta["submittedAt"] = timestamp
        memberDataWithMeta["auditId"] = auditRef.documentID
        
        batch.setData(memberDataWithMeta, forDocument: memberRef)
        
        // Save nominee data
        let nomineeRef = db.collection("users").document(userId).collection("nominees").document()
        let nomineeData = try Firestore.Encoder().encode(nominee)
        var nomineeDataWithMeta = nomineeData
        nomineeDataWithMeta["userId"] = userId
        nomineeDataWithMeta["memberRef"] = memberRef.documentID
        nomineeDataWithMeta["submittedAt"] = timestamp
        nomineeDataWithMeta["auditId"] = auditRef.documentID
        
        batch.setData(nomineeDataWithMeta, forDocument: nomineeRef)
        
        // Save account data (with sensitive info hashed)
        let accountRef = db.collection("users").document(userId).collection("accounts").document()
        var accountData = try Firestore.Encoder().encode(account)
        
        // Hash sensitive account information
        if let accountNumber = accountData["accountNumber"] as? String {
            accountData["accountNumberHash"] = SecurityManager.hashSensitiveData(accountNumber)
            accountData["accountNumber"] = SecurityManager.maskAccountNumber(accountNumber)
        }
        
        accountData["userId"] = userId
        accountData["memberRef"] = memberRef.documentID
        accountData["submittedAt"] = timestamp
        accountData["auditId"] = auditRef.documentID
        
        batch.setData(accountData, forDocument: accountRef)
        
        // Commit all writes atomically
        try await batch.commit()
    }
    
    private func getDeviceInfo() async -> [String: Any] {
        return [
            "platform": "iOS",
            "version": ProcessInfo.processInfo.operatingSystemVersionString,
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        ]
    }
    
    // MARK: - Validation Helpers
    // Validation methods moved to SecurityUtils.swift for consistency
    
    // MARK: - Age Validation
    func isValidAge(_ birthDate: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        return (ageComponents.year ?? 0) >= FormValidationConstants.minimumAge
    }
    
    func getAge(from birthDate: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        return ageComponents.year ?? 0
    }
    
    func ageValidationMessage(for birthDate: Date, personType: String) -> String? {
        let age = getAge(from: birthDate)
        if age < FormValidationConstants.minimumAge {
            return "\(personType) must be at least \(FormValidationConstants.minimumAge) years old. Current age: \(age)"
        }
        return nil
    }
    
    // MARK: - Auto-Save Functionality
    private func setupAutoSave() {
        // Create a combined publisher for all form data changes
        let formDataPublisher = Publishers.CombineLatest(
            Publishers.CombineLatest4(
                Publishers.CombineLatest($member, $memberAddress),
                Publishers.CombineLatest($nominee, $nomineeAddress),
                $account,
                $digitalSignature
            ),
            $currentStep
        )
        .debounce(for: .seconds(2), scheduler: RunLoop.main)
        .sink { [weak self] _ in
            self?.autoSaveDraft()
        }
        
        formDataPublisher.store(in: &cancellables)
    }
    
    private func autoSaveDraft() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(member)
            UserDefaults.standard.set(data, forKey: "kycDraft_\(userId)")
            
            DispatchQueue.main.async {
                self.lastAutoSaved = Date()
            }
            
        } catch {
            print("Failed to save draft locally: \(error)")
        }
    }
    
    struct KYCDraftData: Codable {
        var member: Person?
        var memberAddress: Address?
        var nominee: Person?
        var nomineeAddress: Address?
        var account: Account?
        var digitalSignature: DigitalSignature?
        var lastUpdated: Date?
        
        init(member: Person? = nil, memberAddress: Address? = nil, nominee: Person? = nil, nomineeAddress: Address? = nil, account: Account? = nil, digitalSignature: DigitalSignature? = nil, lastUpdated: Date? = nil) {
            self.member = member
            self.memberAddress = memberAddress
            self.nominee = nominee
            self.nomineeAddress = nomineeAddress
            self.account = account
            self.digitalSignature = digitalSignature
            self.lastUpdated = lastUpdated
        }
    }

    
    private func loadDraftData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // First try to load from local storage
        if let data = UserDefaults.standard.data(forKey: "kycDraft_\(userId)") {
            do {
                let decoder = JSONDecoder()
                let draftData = try decoder.decode(KYCDraftData.self, from: data)
                restoreDraftData(draftData)
                lastAutoSaved = draftData.lastUpdated
                return
            } catch {
                print("Failed to load local draft: \(error)")
            }
        }
    }
    
    private func restoreDraftData(_ draftData: KYCDraftData) {
        if let member = draftData.member {
            self.member = member
        }
        if let memberAddress = draftData.memberAddress {
            self.memberAddress = memberAddress
        }
        if let nominee = draftData.nominee {
            self.nominee = nominee
        }
        if let nomineeAddress = draftData.nomineeAddress {
            self.nomineeAddress = nomineeAddress
        }
        if let account = draftData.account {
            self.account = account
        }
        if let digitalSignature = draftData.digitalSignature {
            self.digitalSignature = digitalSignature
        }
    }
    
    // MARK: - Draft Management
    func clearDraft() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Clear local draft
        UserDefaults.standard.removeObject(forKey: "kycDraft_\(userId)")
        
        // Clear Firestore draft
        db.collection("users").document(userId).collection("drafts").document(userId).delete { error in
            if let error = error {
                print("Failed to delete draft from Firestore: \(error)")
            }
        }
        
        lastAutoSaved = nil
    }
}

