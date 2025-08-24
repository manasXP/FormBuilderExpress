//
//  AuthenticationView.swift
//  FormBuilderExpress
//
//  Created by Manas Pradhan on 10/07/25.
//

import SwiftUI

// MARK: - AuthenticationView
struct AuthenticationView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showPassword = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.6),
                        Color.purple.opacity(0.8),
                        Color.pink.opacity(0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Background blur effect
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .blur(radius: 10)
                    .offset(x: -150, y: -200)
                
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .blur(radius: 10)
                    .offset(x: 150, y: 100)
                
                if viewModel.isAuthenticated {
                    // Authenticated State
                    authenticatedView(user: viewModel.user)
                } else {
                    // Login Form
                    loginFormView()
                }
            }
        }
    }
    
    private func loginFormView() -> some View {
        ScrollView {
            VStack(spacing: 0) {
                AuthHeaderView()
                    .padding(.bottom, 50)
                
                AuthFormCardView(
                    emailOrPhone: $viewModel.emailOrPhone,
                    password: $viewModel.password,
                    showPassword: $showPassword,
                    errorMessage: viewModel.errorMessage,
                    isLoading: viewModel.isLoading,
                    onSignIn: { viewModel.signIn() }
                )
                .padding(.horizontal, 24)
                
                Spacer(minLength: 40)
            }
        }
    }
    
    private func authenticatedView(user: AuthModel?) -> some View {
        VStack(spacing: 32) {
            // Success Animation
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
            }
            .padding(.top, 100)
            
            VStack(spacing: 16) {
                Text("Welcome!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("You're successfully signed in")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // User Info Card
            if let user = user {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        if let email = user.email {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.blue)
                                Text(email)
                                    .font(.system(size: 14, weight: .medium))
                                Spacer()
                            }
                        }
                        
                        if let phone = user.phoneNumber {
                            HStack {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.green)
                                Text(phone)
                                    .font(.system(size: 14, weight: .medium))
                                Spacer()
                            }
                        }
                        
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.purple)
                            Text("ID: \(user.uid.prefix(8))...")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
            }
            
            // Sign Out Button
            Button(action: {
                viewModel.signOut()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.right.square")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Sign Out")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

#Preview {
    AuthenticationView()
}

// MARK: - Supporting Views
struct AuthHeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            // App Icon/Logo placeholder
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .blur(radius: 10)
                    )
                
                Image(systemName: "lock.shield")
                    .font(.system(size: 35))
                    .foregroundColor(.white)
            }
            .padding(.top, 60)
            
            VStack(spacing: 8) {
                Text("Welcome Back")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Sign in to continue your journey")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

struct AuthFormCardView: View {
    @Binding var emailOrPhone: String
    @Binding var password: String
    @Binding var showPassword: Bool
    let errorMessage: String
    let isLoading: Bool
    let onSignIn: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            AuthInputFieldView(
                title: "Email or Phone",
                placeholder: "Enter your email or phone",
                text: $emailOrPhone,
                iconName: "envelope"
            )
            
            AuthPasswordFieldView(
                text: $password,
                showPassword: $showPassword
            )
            
            if !errorMessage.isEmpty {
                AuthErrorMessageView(message: errorMessage)
            }
            
            AuthSignInButtonView(
                isLoading: isLoading,
                action: onSignIn
            )
            
            AuthForgotPasswordView()
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 36)
        .background(AuthFormBackgroundView())
    }
}

struct AuthInputFieldView: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let iconName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
}

struct AuthPasswordFieldView: View {
    @Binding var text: String
    @Binding var showPassword: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Password")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "lock")
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                if showPassword {
                    TextField("Enter your password", text: $text)
                } else {
                    SecureField("Enter your password", text: $text)
                }
                
                Button(action: {
                    showPassword.toggle()
                }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
}

struct AuthErrorMessageView: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.red)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
}

struct AuthSignInButtonView: View {
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.9)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(isLoading ? "Signing In..." : "Sign In")
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(isLoading)
        .scaleEffect(isLoading ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isLoading)
    }
}

struct AuthForgotPasswordView: View {
    var body: some View {
        Button(action: {
            // Handle forgot password
        }) {
            Text("Forgot Password?")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .underline()
        }
        .padding(.top, 8)
    }
}

struct AuthFormBackgroundView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(Color.white.opacity(0.15))
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.1))
                    .blur(radius: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}
