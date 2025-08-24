//
//  HamburgerMenuView.swift
//  FormBuilderExpress
//
//  Created by Manas Pradhan on 24/08/25.
//

import SwiftUI

// MARK: - Hamburger Menu Overlay (Sliding Menu Content)
struct HamburgerMenuOverlay: View {
    @Binding var isMenuOpen: Bool
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isMenuOpen = false
                    }
                }
            
            // Sliding menu panel
            HStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 0) {
                    // Menu header with themed styling
                    HStack {
                        Text("Menu")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .padding(.leading, 20)
                            .padding(.top, 20)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isMenuOpen = false
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(AppTheme.Colors.primaryText)
                                .padding()
                        }
                    }
                    .background(AppTheme.Colors.backgroundGradient)
                    
                    Divider()
                        .background(AppTheme.Colors.primaryText.opacity(0.3))
                        .padding(.horizontal, 20)
                    
                    // User info section with themed styling
                    if let user = authViewModel.user {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Signed in as:")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                            
                            Text(user.email ?? user.phoneNumber ?? "Unknown User")
                                .font(AppTheme.Typography.bodySmall)
                                .fontWeight(.medium)
                                .foregroundColor(AppTheme.Colors.primaryText)
                                .padding(.horizontal, 20)
                        }
                        .background(Color(UIColor.systemBackground))
                        
                        Divider()
                            .background(AppTheme.Colors.primaryText.opacity(0.3))
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                    }
                    
                    // Logout button with themed styling
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isMenuOpen = false
                        }
                        authViewModel.signOut()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(AppTheme.Colors.errorColor)
                            
                            Text("Logout")
                                .foregroundColor(AppTheme.Colors.errorColor)
                                .font(AppTheme.Typography.bodySmall)
                                .fontWeight(.medium)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .background(Color(UIColor.systemBackground))
                    
                    Spacer()
                }
                .frame(width: 280)
                .background(Color(UIColor.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 0))
                .shadow(color: AppTheme.Shadows.medium, radius: 10)
                .transition(.move(edge: .trailing))
            }
        }
    }
}

// MARK: - Legacy HamburgerMenuView (kept for compatibility)
struct HamburgerMenuView: View {
    @Binding var isMenuOpen: Bool
    
    var body: some View {
        // This is now just a wrapper that shows the overlay when needed
        if isMenuOpen {
            HamburgerMenuOverlay(isMenuOpen: $isMenuOpen)
        }
    }
}

#Preview {
    HamburgerMenuOverlay(isMenuOpen: .constant(true))
        .environmentObject(AuthViewModel())
}