//
//  KYCFormViewModelTests.swift
//  FormBuilderExpressTests
//
//  Created by Claude on 22/08/25.
//

import XCTest
import Combine
@testable import FormBuilderExpress

final class KYCFormViewModelTests: XCTestCase {
    var viewModel: KYCFormViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        viewModel = KYCFormViewModel()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        cancellables = nil
    }

    // MARK: - Validation Tests
    
    func testMemberInfoValidation_ValidData_ShouldReturnTrue() {
        // Given
        viewModel.member.name.first = "John"
        viewModel.member.name.last = "Doe"
        viewModel.member.email = "john.doe@example.com"
        viewModel.member.phone = "1234567890"
        
        // When
        let expectation = XCTestExpectation(description: "Member validation should complete")
        
        viewModel.$isMemberInfoValid
            .dropFirst()
            .sink { isValid in
                // Then
                XCTAssertTrue(isValid)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testMemberInfoValidation_InvalidEmail_ShouldReturnFalse() {
        // Given
        viewModel.member.name.first = "John"
        viewModel.member.name.last = "Doe"
        viewModel.member.email = "invalid-email"
        viewModel.member.phone = "1234567890"
        
        // When
        let expectation = XCTestExpectation(description: "Member validation should complete")
        
        viewModel.$isMemberInfoValid
            .dropFirst()
            .sink { isValid in
                // Then
                XCTAssertFalse(isValid)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddressValidation_ValidData_ShouldReturnTrue() {
        // Given
        viewModel.memberAddress.addressLine1 = "123 Main St"
        viewModel.memberAddress.city = "New York"
        viewModel.memberAddress.state = "NY"
        viewModel.memberAddress.zipCode = "10001"
        
        // When
        let expectation = XCTestExpectation(description: "Address validation should complete")
        
        viewModel.$isMemberAddressValid
            .dropFirst()
            .sink { isValid in
                // Then
                XCTAssertTrue(isValid)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAccountValidation_ValidData_ShouldReturnTrue() {
        // Given
        viewModel.account.accountHolderName = "John Doe"
        viewModel.account.bankName = "Test Bank"
        viewModel.account.accountNumber = "12345678"
        viewModel.account.confirmAccountNumber = "12345678"
        viewModel.account.routingNumber = "021000021" // Valid test routing number
        
        // When
        let expectation = XCTestExpectation(description: "Account validation should complete")
        
        viewModel.$isAccountValid
            .dropFirst()
            .sink { isValid in
                // Then
                XCTAssertTrue(isValid)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAccountValidation_MismatchedAccountNumbers_ShouldReturnFalse() {
        // Given
        viewModel.account.accountHolderName = "John Doe"
        viewModel.account.bankName = "Test Bank"
        viewModel.account.accountNumber = "12345678"
        viewModel.account.confirmAccountNumber = "87654321"
        viewModel.account.routingNumber = "021000021"
        
        // When
        let expectation = XCTestExpectation(description: "Account validation should complete")
        
        viewModel.$isAccountValid
            .dropFirst()
            .sink { isValid in
                // Then
                XCTAssertFalse(isValid)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Navigation Tests
    
    func testCanProceedToNext_ValidMemberInfo_ShouldReturnTrue() {
        // Given
        viewModel.currentStep = .memberInfo
        viewModel.isMemberInfoValid = true
        
        // When
        let canProceed = viewModel.canProceedToNext()
        
        // Then
        XCTAssertTrue(canProceed)
    }
    
    func testCanProceedToNext_InvalidMemberInfo_ShouldReturnFalse() {
        // Given
        viewModel.currentStep = .memberInfo
        viewModel.isMemberInfoValid = false
        
        // When
        let canProceed = viewModel.canProceedToNext()
        
        // Then
        XCTAssertFalse(canProceed)
    }
    
    // MARK: - Validation Helper Tests
    
    func testIsValidEmail_ValidEmail_ShouldReturnTrue() {
        // Given
        let validEmails = [
            "test@example.com",
            "user.name@domain.co.uk",
            "user+tag@example.org"
        ]
        
        for email in validEmails {
            // When
            let isValid = viewModel.isValidEmail(email)
            
            // Then
            XCTAssertTrue(isValid, "Email \(email) should be valid")
        }
    }
    
    func testIsValidEmail_InvalidEmail_ShouldReturnFalse() {
        // Given
        let invalidEmails = [
            "invalid-email",
            "@example.com",
            "test@",
            "test.example.com",
            ""
        ]
        
        for email in invalidEmails {
            // When
            let isValid = viewModel.isValidEmail(email)
            
            // Then
            XCTAssertFalse(isValid, "Email \(email) should be invalid")
        }
    }
    
    func testIsValidRoutingNumber_ValidRoutingNumber_ShouldReturnTrue() {
        // Given
        let validRoutingNumbers = [
            "021000021", // Bank of America
            "111000025", // Federal Reserve Bank
            "026009593"  // Bank of America
        ]
        
        for routingNumber in validRoutingNumbers {
            // When
            let isValid = viewModel.isValidRoutingNumber(routingNumber)
            
            // Then
            XCTAssertTrue(isValid, "Routing number \(routingNumber) should be valid")
        }
    }
    
    func testIsValidRoutingNumber_InvalidRoutingNumber_ShouldReturnFalse() {
        // Given
        let invalidRoutingNumbers = [
            "123456789", // Invalid checksum
            "12345678",  // Too short
            "1234567890", // Too long
            "abcdefghi",  // Non-numeric
            ""           // Empty
        ]
        
        for routingNumber in invalidRoutingNumbers {
            // When
            let isValid = viewModel.isValidRoutingNumber(routingNumber)
            
            // Then
            XCTAssertFalse(isValid, "Routing number \(routingNumber) should be invalid")
        }
    }
    
    // MARK: - Form State Tests
    
    func testInitialState() {
        // Then
        XCTAssertEqual(viewModel.currentStep, .memberInfo)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isMemberInfoValid)
        XCTAssertFalse(viewModel.isMemberAddressValid)
        XCTAssertFalse(viewModel.isNomineeInfoValid)
        XCTAssertFalse(viewModel.isNomineeAddressValid)
        XCTAssertFalse(viewModel.isAccountValid)
        XCTAssertFalse(viewModel.isSignatureValid)
    }
    
    func testClearDraft() {
        // Given
        viewModel.member.name.first = "Test"
        viewModel.memberAddress.city = "Test City"
        viewModel.lastAutoSaved = Date()
        
        // When
        viewModel.clearDraft()
        
        // Then
        XCTAssertNil(viewModel.lastAutoSaved)
    }
}

// MARK: - Security Tests
final class SecurityUtilsTests: XCTestCase {
    
    func testStringsanitization() {
        // Given
        let maliciousInput = "<script>alert('xss')</script>Hello World"
        
        // When
        let sanitized = maliciousInput.sanitized
        
        // Then
        XCTAssertEqual(sanitized, "Hello World")
        XCTAssertFalse(sanitized.contains("<script>"))
    }
    
    func testEmailValidation() {
        // Given
        let validEmail = "test@example.com"
        let invalidEmail = "<script>alert()</script>test@example.com"
        
        // When & Then
        XCTAssertTrue(validEmail.isValidEmail)
        XCTAssertFalse(invalidEmail.isValidEmail)
    }
    
    func testNameValidation() {
        // Given
        let validName = "John Doe-Smith"
        let invalidName = "John<script>alert()</script>"
        
        // When & Then
        XCTAssertTrue(validName.isValidName)
        XCTAssertFalse(invalidName.isValidName)
    }
    
    func testAccountNumberMasking() {
        // Given
        let accountNumber = "1234567890"
        
        // When
        let masked = SecurityManager.maskAccountNumber(accountNumber)
        
        // Then
        XCTAssertEqual(masked, "******7890")
    }
    
    func testEmailMasking() {
        // Given
        let email = "john.doe@example.com"
        
        // When
        let masked = SecurityManager.maskEmail(email)
        
        // Then
        XCTAssertEqual(masked, "jo******@example.com")
    }
    
    func testHashSensitiveData() {
        // Given
        let sensitiveData = "1234567890"
        
        // When
        let hash1 = SecurityManager.hashSensitiveData(sensitiveData)
        let hash2 = SecurityManager.hashSensitiveData(sensitiveData)
        
        // Then
        XCTAssertEqual(hash1, hash2) // Same input should produce same hash
        XCTAssertNotEqual(hash1, sensitiveData) // Hash should be different from input
    }
}

// MARK: - Form Security Validation Tests
final class FormSecurityValidatorTests: XCTestCase {
    
    func testSanitizePersonData() {
        // Given
        var person = Person()
        person.name.first = "<script>John</script>"
        person.name.last = "Doe<alert>"
        person.email = "test@example.com<script>"
        
        // When
        let sanitized = FormSecurityValidator.sanitizePersonData(person)
        
        // Then
        XCTAssertEqual(sanitized.name.first, "John")
        XCTAssertEqual(sanitized.name.last, "Doe")
        XCTAssertEqual(sanitized.email, "test@example.com")
    }
    
    func testSanitizeAddressData() {
        // Given
        var address = Address()
        address.addressLine1 = "123<script> Main St"
        address.city = "New<alert> York"
        
        // When
        let sanitized = FormSecurityValidator.sanitizeAddressData(address)
        
        // Then
        XCTAssertEqual(sanitized.addressLine1, "123 Main St")
        XCTAssertEqual(sanitized.city, "New York")
    }
}