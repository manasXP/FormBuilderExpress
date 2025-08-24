//
//  HamburgerMenuView.swift
//  FormBuilderExpress
//
//  Created by Manas Pradhan on 24/08/25.
//

import SwiftUI

struct HamburgerMenuView: View {
    @Binding var isMenuOpen: Bool
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isMenuOpen.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .padding()
                }
            }
            
            Spacer()
        }
        .overlay(
            // Menu overlay
            Group {
                if isMenuOpen {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isMenuOpen = false
                            }
                        }
                    
                    HStack {
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("Menu")
                                    .font(.headline)
                                    .padding(.leading, 20)
                                    .padding(.top, 20)
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isMenuOpen = false
                                    }
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.title2)
                                        .foregroundColor(.primary)
                                        .padding()
                                }
                            }
                            
                            Divider()
                                .padding(.horizontal, 20)
                            
                            if let user = authViewModel.user {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Signed in as:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 20)
                                        .padding(.top, 16)
                                    
                                    Text(user.email ?? user.phoneNumber ?? "Unknown User")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 20)
                                }
                                
                                Divider()
                                    .padding(.horizontal, 20)
                                    .padding(.top, 16)
                            }
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isMenuOpen = false
                                }
                                authViewModel.signOut()
                            }) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .foregroundColor(.red)
                                    
                                    Text("Logout")
                                        .foregroundColor(.red)
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                            }
                            
                            Spacer()
                        }
                        .frame(width: 280)
                        .background(Color(UIColor.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 0))
                        .shadow(radius: 10)
                        .transition(.move(edge: .trailing))
                    }
                }
            }
        )
    }
}

#Preview {
    HamburgerMenuView(isMenuOpen: .constant(true))
        .environmentObject(AuthViewModel())
}