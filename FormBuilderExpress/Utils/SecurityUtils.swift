//
//  SecurityUtils.swift
//  FormBuilderExpress
//
//  Created by Claude on 22/08/25.
//

import Foundation
import CryptoKit

// MARK: - Input Sanitization
extension String {
    // Remove potentially dangerous characters and scripts
    var sanitized: String {
        // Remove HTML tags and scripts
        let htmlPattern = "<[^>]+>"
        let scriptPattern = "(?i)<script[^>]*>.*?</script>"
        let sqlPattern = "('|(\\-\\-)|(;)|(\\||\\|)|(\\*|\\*)|(%)|(<)|(>)|(\\+)|(=))"
        
        var cleaned = self
        
        // Remove HTML/XML tags
        cleaned = cleaned.replacingOccurrences(of: htmlPattern, with: "", options: .regularExpression)
        
        // Remove script tags
        cleaned = cleaned.replacingOccurrences(of: scriptPattern, with: "", options: .regularExpression)
        
        // Remove common SQL injection patterns
        cleaned = cleaned.replacingOccurrences(of: sqlPattern, with: "", options: .regularExpression)
        
        // Trim whitespace and newlines
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Limit length to prevent buffer overflow
        if cleaned.count > FormValidationConstants.sanitizedFieldMaxLength {
            cleaned = String(cleaned.prefix(FormValidationConstants.sanitizedFieldMaxLength))
        }
        
        return cleaned
    }
    
    // Sanitize for safe display (encode special characters)
    var encodedForDisplay: String {
        return self
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
    
    // Validate phone number format (handles both formatted and unformatted numbers)
    var isValidPhoneNumber: Bool {
        print("📞 Phone validation for original: '\(self)'")
        
        // Extract only digits from the phone number (ignore formatting)
        let digitsOnly = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        print("📞 Phone digits only: '\(digitsOnly)'")
        
        // Check if we have exactly 10 digits for US phone numbers
        guard digitsOnly.count == 10 else {
            print("📞 Phone validation failed: wrong digit count (\(digitsOnly.count))")
            return false
        }
        
        // Validate that area code (first 3 digits) doesn't start with 0 or 1
        guard let firstDigit = digitsOnly.first,
              firstDigit != "0" && firstDigit != "1" else {
            print("📞 Phone validation failed: invalid area code")
            return false
        }
        
        // Validate that exchange code (4th digit) doesn't start with 0 or 1
        let exchangeIndex = digitsOnly.index(digitsOnly.startIndex, offsetBy: 3)
        guard let exchangeDigit = digitsOnly[exchangeIndex].wholeNumberValue,
              exchangeDigit != 0 && exchangeDigit != 1 else {
            print("📞 Phone validation failed: invalid exchange code")
            return false
        }
        
        print("📞 Phone validation result: true")
        return true
    }
    
    // Validate email format
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self.sanitized)
    }
    
    // Validate name (alphabetic characters, spaces, hyphens, apostrophes only)
    var isValidName: Bool {
        let nameRegex = "^[a-zA-Z\\s\\-']{1,\(FormValidationConstants.standardFieldMaxLength)}$"
        let namePredicate = NSPredicate(format:"SELF MATCHES %@", nameRegex)
        return namePredicate.evaluate(with: self.sanitized)
    }
    
    // Validate address (alphanumeric, spaces, commas, periods, hyphens)
    var isValidAddress: Bool {
        let addressRegex = "^[a-zA-Z0-9\\s\\.,\\-#/]{1,\(FormValidationConstants.standardFieldMaxLength)}$"
        let addressPredicate = NSPredicate(format:"SELF MATCHES %@", addressRegex)
        return addressPredicate.evaluate(with: self.sanitized)
    }
    
    // Validate routing number (9 digits)
    var isValidRoutingNumber: Bool {
        guard self.count == 9, self.allSatisfy({ $0.isNumber }) else {
            return false
        }
        
        let digits = self.compactMap { Int(String($0)) }
        let checksum = (3 * (digits[0] + digits[3] + digits[6]) +
                       7 * (digits[1] + digits[4] + digits[7]) +
                       1 * (digits[2] + digits[5] + digits[8])) % 10
        
        return checksum == 0
    }
    
    // Validate account number (8-17 digits)
    var isValidAccountNumber: Bool {
        let accountRegex = "^[0-9]{8,17}$"
        let accountPredicate = NSPredicate(format:"SELF MATCHES %@", accountRegex)
        return accountPredicate.evaluate(with: self.sanitized)
    }
    
    // Validate zip code (6 numeric characters only)
    var isValidZipCode: Bool {
        let zipRegex = "^[0-9]{6}$"
        let zipPredicate = NSPredicate(format:"SELF MATCHES %@", zipRegex)
        return zipPredicate.evaluate(with: self.sanitized)
    }
    
    // Validate general text field with standard character limit
    var isValidTextField: Bool {
        let sanitizedText = self.sanitized
        return !sanitizedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               sanitizedText.count <= FormValidationConstants.standardFieldMaxLength
    }
    
    // Validate city field
    var isValidCity: Bool {
        let cityRegex = "^[a-zA-Z\\s\\-']{1,\(FormValidationConstants.standardFieldMaxLength)}$"
        let cityPredicate = NSPredicate(format:"SELF MATCHES %@", cityRegex)
        return cityPredicate.evaluate(with: self.sanitized)
    }
    
    // Validate state field
    var isValidState: Bool {
        let stateRegex = "^[a-zA-Z\\s\\-']{1,\(FormValidationConstants.standardFieldMaxLength)}$"
        let statePredicate = NSPredicate(format:"SELF MATCHES %@", stateRegex)
        return statePredicate.evaluate(with: self.sanitized)
    }
    
    // Validate bank name field
    var isValidBankName: Bool {
        let bankNameRegex = "^[a-zA-Z0-9\\s\\.,\\-&']{1,\(FormValidationConstants.standardFieldMaxLength)}$"
        let bankNamePredicate = NSPredicate(format:"SELF MATCHES %@", bankNameRegex)
        return bankNamePredicate.evaluate(with: self.sanitized)
    }
    
    // Validate account holder name
    var isValidAccountHolderName: Bool {
        let accountHolderRegex = "^[a-zA-Z\\s\\-']{1,\(FormValidationConstants.standardFieldMaxLength)}$"
        let accountHolderPredicate = NSPredicate(format:"SELF MATCHES %@", accountHolderRegex)
        return accountHolderPredicate.evaluate(with: self.sanitized)
    }
}

// MARK: - Data Encryption
struct SecurityManager {
    
    // Generate a secure hash of sensitive data
    static func hashSensitiveData(_ data: String) -> String {
        let inputData = Data(data.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    // Mask sensitive information for display
    static func maskAccountNumber(_ accountNumber: String) -> String {
        guard accountNumber.count >= 4 else { return "****" }
        let masked = String(repeating: "*", count: accountNumber.count - 4)
        let lastFour = String(accountNumber.suffix(4))
        return masked + lastFour
    }
    
    static func maskEmail(_ email: String) -> String {
        let components = email.components(separatedBy: "@")
        guard components.count == 2,
              let username = components.first,
              let domain = components.last,
              username.count > 2 else {
            return "****@****.com"
        }
        
        let maskedUsername = String(username.prefix(2)) + String(repeating: "*", count: max(0, username.count - 2))
        return maskedUsername + "@" + domain
    }
    
    // Validate file upload security
    static func isSecureFileType(_ url: URL) -> Bool {
        let allowedExtensions = ["pdf", "jpg", "jpeg", "png", "doc", "docx"]
        let fileExtension = url.pathExtension.lowercased()
        return allowedExtensions.contains(fileExtension)
    }
    
    static func isValidFileSize(_ url: URL, maxSizeMB: Int = 10) -> Bool {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = attributes[FileAttributeKey.size] as? Int64 {
                let maxSizeBytes = Int64(maxSizeMB * 1024 * 1024)
                return fileSize <= maxSizeBytes
            }
        } catch {
            print("Error getting file size: \(error)")
        }
        return false
    }
}

// MARK: - Rate Limiting
class RateLimiter {
    private var attempts: [Date] = []
    private let maxAttempts: Int
    private let timeWindow: TimeInterval
    
    init(maxAttempts: Int = 5, timeWindowMinutes: Int = 15) {
        self.maxAttempts = maxAttempts
        self.timeWindow = TimeInterval(timeWindowMinutes * 60)
    }
    
    func isAllowed() -> Bool {
        let now = Date()
        
        // Remove attempts outside the time window
        attempts = attempts.filter { now.timeIntervalSince($0) < timeWindow }
        
        if attempts.count >= maxAttempts {
            return false
        }
        
        attempts.append(now)
        return true
    }
    
    func timeUntilNextAttempt() -> TimeInterval? {
        guard attempts.count >= maxAttempts,
              let oldestAttempt = attempts.first else {
            return nil
        }
        
        let timeElapsed = Date().timeIntervalSince(oldestAttempt)
        return max(0, timeWindow - timeElapsed)
    }
}

// MARK: - Form Validation Security
struct FormSecurityValidator {
    private static let submitRateLimiter = RateLimiter(maxAttempts: 3, timeWindowMinutes: 10)
    
    static func validateFormSubmission() -> (isValid: Bool, errorMessage: String?) {
        guard submitRateLimiter.isAllowed() else {
            let waitTime = submitRateLimiter.timeUntilNextAttempt() ?? 0
            let minutes = Int(waitTime / 60)
            return (false, "Too many submission attempts. Please wait \(minutes + 1) minutes before trying again.")
        }
        
        return (true, nil)
    }
    
    static func sanitizePersonData(_ person: Person) -> Person {
        var sanitizedPerson = person
        sanitizedPerson.name.first = person.name.first.sanitized
        sanitizedPerson.name.middle = person.name.middle.sanitized
        sanitizedPerson.name.last = person.name.last.sanitized
        sanitizedPerson.email = person.email.sanitized
        sanitizedPerson.phone = person.phone.sanitized
        return sanitizedPerson
    }
    
    static func sanitizeAddressData(_ address: Address) -> Address {
        var sanitizedAddress = address
        sanitizedAddress.addressLine1 = address.addressLine1.sanitized
        sanitizedAddress.addressLine2 = address.addressLine2.sanitized
        sanitizedAddress.city = address.city.sanitized
        sanitizedAddress.state = address.state.sanitized
        sanitizedAddress.zipCode = address.zipCode.sanitized
        return sanitizedAddress
    }
    
    static func sanitizeAccountData(_ account: Account) -> Account {
        var sanitizedAccount = account
        sanitizedAccount.accountHolderName = account.accountHolderName.sanitized
        sanitizedAccount.bankName = account.bankName.sanitized
        sanitizedAccount.accountNumber = account.accountNumber.sanitized
        sanitizedAccount.routingNumber = account.routingNumber.sanitized
        return sanitizedAccount
    }
}
