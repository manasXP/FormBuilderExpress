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
    @Published var currentStep: DataView = .memberInfo
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
            .map { member in
                !member.name.first.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty &&
                !member.name.last.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty &&
                self.isValidEmail(member.email) &&
                !member.phone.isEmpty
            }
            .assign(to: &$isMemberInfoValid)
        
        // Member address validation
        $memberAddress
            .map { address in
                !address.addressLine1.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty &&
                !address.city.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty &&
                !address.state.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty &&
                !address.zipCode.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
            }
            .assign(to: &$isMemberAddressValid)
        
        // Nominee info validation
        $nominee
            .map { nominee in
                !nominee.name.first.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty &&
                !nominee.name.last.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty &&
                self.isValidEmail(nominee.email) &&
                !nominee.phone.isEmpty
            }
            .assign(to: &$isNomineeInfoValid)
        
        // Nominee address validation
        $nomineeAddress
            .map { address in
                !address.addressLine1.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty &&
                !address.city.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty &&
                !address.state.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty &&
                !address.zipCode.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
            }
            .assign(to: &$isNomineeAddressValid)
        
        // Account validation
        $account
            .map { account in
                !account.accountHolderName.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty &&
                !account.accountNumber.isEmpty &&
                account.accountNumber.count >= 8 &&
                account.routingNumber.count == 9 &&
                self.isValidRoutingNumber(account.routingNumber) &&
                !account.bankName.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty &&
                account.accountNumber == account.confirmAccountNumber
            }
            .assign(to: &$isAccountValid)
    }
    
    // MARK: - Navigation Methods
    func canProceedToNext() -> Bool {
        switch currentStep {
        case .memberInfo: return isMemberInfoValid
        case .memberAddress: return isMemberAddressValid
        case .nomineeInfo: return isNomineeInfoValid
        case .nomineeAddress: return isNomineeAddressValid
        case .memberBankDetails: return isAccountValid
        case .summary: return true
        }
    }
    
    // MARK: - Data Persistence Methods
    func addMember(member: Person) {
        let collectionRef = db.collection("members")
        do {
            let newDocReference = try collectionRef.addDocument(from: member)
            print("Member stored with new document reference: \(newDocReference)")
        }
        catch {
            print(error)
        }
    }
    
    func addNominee(nominee: Person) {
        let collectionRef = db.collection("nominees")
        do {
            let newDocReference = try collectionRef.addDocument(from: nominee)
            print("Nominee stored with new document reference: \(newDocReference)")
        }
        catch {
            print(error)
        }
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
        
        // Create audit trail entry
        let auditData: [String: Any] = [
            "userId": userId,
            "action": "kyc_form_submission",
            "timestamp": timestamp,
            "deviceInfo": await getDeviceInfo()
        ]
        
        let auditRef = db.collection("audit_logs").document()
        batch.setData(auditData, forDocument: auditRef)
        
        // Save member data
        let memberRef = db.collection("members").document()
        let memberData = try Firestore.Encoder().encode(member)
        var memberDataWithMeta = memberData
        memberDataWithMeta["userId"] = userId
        memberDataWithMeta["submittedAt"] = timestamp
        memberDataWithMeta["auditId"] = auditRef.documentID
        
        batch.setData(memberDataWithMeta, forDocument: memberRef)
        
        // Save nominee data
        let nomineeRef = db.collection("nominees").document()
        let nomineeData = try Firestore.Encoder().encode(nominee)
        var nomineeDataWithMeta = nomineeData
        nomineeDataWithMeta["userId"] = userId
        nomineeDataWithMeta["memberRef"] = memberRef.documentID
        nomineeDataWithMeta["submittedAt"] = timestamp
        nomineeDataWithMeta["auditId"] = auditRef.documentID
        
        batch.setData(nomineeDataWithMeta, forDocument: nomineeRef)
        
        // Save account data (with sensitive info hashed)
        let accountRef = db.collection("accounts").document()
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
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidRoutingNumber(_ routing: String) -> Bool {
        guard routing.count == 9, routing.allSatisfy({ $0.isNumber }) else {
            return false
        }
        
        let digits = routing.compactMap { Int(String($0)) }
        let checksum = (3 * (digits[0] + digits[3] + digits[6]) +
                       7 * (digits[1] + digits[4] + digits[7]) +
                       1 * (digits[2] + digits[5] + digits[8])) % 10
        
        return checksum == 0
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
        
        let draftData = KYCDraftData(
            member: member,
            memberAddress: memberAddress,
            nominee: nominee,
            nomineeAddress: nomineeAddress,
            account: account,
            digitalSignature: digitalSignature,
            currentStep: currentStep,
            lastUpdated: Date()
        )
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(draftData)
            UserDefaults.standard.set(data, forKey: "kycDraft_\(userId)")
            
            DispatchQueue.main.async {
                self.lastAutoSaved = Date()
            }
            
            // Also save to Firestore for cloud backup
            saveDraftToFirestore(draftData, userId: userId)
            
        } catch {
            print("Failed to save draft locally: \(error)")
        }
    }
    
    private func saveDraftToFirestore(_ draftData: KYCDraftData, userId: String) {
        let draftRef = db.collection("drafts").document(userId)
        
        Task {
            do {
                try draftRef.setData(from: draftData, merge: true)
            } catch {
                print("Failed to save draft to Firestore: \(error)")
            }
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
        
        // If local draft fails, try to load from Firestore
        loadDraftFromFirestore(userId: userId)
    }
    
    private func loadDraftFromFirestore(userId: String) {
        let draftRef = db.collection("drafts").document(userId)
        
        draftRef.getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Failed to load draft from Firestore: \(error)")
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else { return }
            
            Task { @MainActor in
                do {
                    let draftData = try snapshot.data(as: KYCDraftData.self)
                    self?.restoreDraftData(draftData)
                    self?.lastAutoSaved = draftData.lastUpdated
                } catch {
                    print("Failed to decode draft from Firestore: \(error)")
                }
            }
        }
    }
    
    private func restoreDraftData(_ draftData: KYCDraftData) {
        member = draftData.member
        memberAddress = draftData.memberAddress
        nominee = draftData.nominee
        nomineeAddress = draftData.nomineeAddress
        account = draftData.account
        digitalSignature = draftData.digitalSignature
        currentStep = draftData.getCurrentStepEnum()
    }
    
    // MARK: - Draft Management
    func clearDraft() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Clear local draft
        UserDefaults.standard.removeObject(forKey: "kycDraft_\(userId)")
        
        // Clear Firestore draft
        db.collection("drafts").document(userId).delete { error in
            if let error = error {
                print("Failed to delete draft from Firestore: \(error)")
            }
        }
        
        lastAutoSaved = nil
    }
}

// MARK: - KYC Draft Data Model
struct KYCDraftData: Codable {
    let member: Person
    let memberAddress: Address
    let nominee: Person
    let nomineeAddress: Address
    let account: Account
    let digitalSignature: DigitalSignature
    let currentStep: String  // Changed from DataView to String for Codable compliance
    let lastUpdated: Date
    
    init(member: Person, memberAddress: Address, nominee: Person, nomineeAddress: Address, account: Account, digitalSignature: DigitalSignature, currentStep: DataView, lastUpdated: Date) {
        self.member = member
        self.memberAddress = memberAddress
        self.nominee = nominee
        self.nomineeAddress = nomineeAddress
        self.account = account
        self.digitalSignature = digitalSignature
        self.currentStep = currentStep.rawValue
        self.lastUpdated = lastUpdated
    }
    
    func getCurrentStepEnum() -> DataView {
        return DataView(rawValue: currentStep) ?? .memberInfo
    }
}
