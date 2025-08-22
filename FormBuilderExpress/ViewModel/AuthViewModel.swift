//
//  AuthViewModel.swift
//  FormBuilderExpress
//
//  Created by Manas Pradhan on 10/07/25.
//

import SwiftUI
import FirebaseAuth
import Combine

// MARK: - AuthViewModel
class AuthViewModel: ObservableObject {
    @Published var emailOrPhone: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var user: AuthModel?
    @Published var isAuthenticated: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        // Listen for authentication state changes
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.user = AuthModel(from: user)
                    self?.isAuthenticated = true
                } else {
                    self?.user = nil
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func signIn() {
        guard !emailOrPhone.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email/phone and password"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        // Determine if input is email or phone number
        if isValidEmail(emailOrPhone) {
            signInWithEmail()
        } else if isValidPhoneNumber(emailOrPhone) {
            signInWithPhone()
        } else {
            errorMessage = "Please enter a valid email address or phone number"
            isLoading = false
        }
    }
    
    private func signInWithEmail() {
        Auth.auth().signIn(withEmail: emailOrPhone, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = self?.mapAuthError(error) ?? "Authentication failed"
                } else {
                    self?.clearForm()
                }
            }
        }
    }
    
    private func signInWithPhone() {
        // For phone authentication, you would typically use Firebase Phone Auth
        // This is a simplified version - in reality, you'd need to implement OTP verification
        errorMessage = "Phone authentication requires OTP verification. Please implement phone auth flow."
        isLoading = false
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            clearForm()
        } catch {
            errorMessage = "Failed to sign out: \(error.localizedDescription)"
        }
    }
    
    private func clearForm() {
        emailOrPhone = ""
        password = ""
        errorMessage = ""
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = "^\\+?[1-9]\\d{1,14}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }
    
    private func mapAuthError(_ error: Error) -> String {
        let authError = error as NSError
        
        switch authError.code {
        case AuthErrorCode.invalidEmail.rawValue:
            return "Invalid email address"
        case AuthErrorCode.userNotFound.rawValue:
            return "No account found with this email"
        case AuthErrorCode.wrongPassword.rawValue:
            return "Incorrect password"
        case AuthErrorCode.userDisabled.rawValue:
            return "This account has been disabled"
        case AuthErrorCode.tooManyRequests.rawValue:
            return "Too many failed attempts. Please try again later"
        case AuthErrorCode.networkError.rawValue:
            return "Network error. Please check your connection"
        default:
            return "Authentication failed: \(error.localizedDescription)"
        }
    }
}
