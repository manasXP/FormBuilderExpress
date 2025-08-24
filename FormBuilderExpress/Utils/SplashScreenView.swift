//
//  SplashScreenView.swift
//  FormBuilderExpress
//
//  Created by Manas Pradhan on 24/08/25.
//

import SwiftUI

struct SplashScreenView: View {
    @Binding var showSplashScreen: Bool
    @State private var isAnimating = false
    @State private var logoScale: CGFloat = 0.5
    @State private var logoRotation: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Use the same themed background as Sign in screen
                AppTheme.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                // Background blur effects matching Sign in screen
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
                
                VStack {
                    Spacer()
                    
                    // Logo section with enhanced animations
                    VStack(spacing: AppTheme.Spacing.xl) {
                        ZStack {
                            // Outer glow ring
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                .frame(width: 140, height: 140)
                                .scaleEffect(isAnimating ? 1.3 : 1.0)
                                .opacity(isAnimating ? 0.3 : 0.8)
                                .animation(
                                    Animation.easeInOut(duration: 2.0)
                                        .repeatForever(autoreverses: true),
                                    value: isAnimating
                                )
                            
                            // Main logo background
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 120, height: 120)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                        .blur(radius: 10)
                                )
                                .scaleEffect(logoScale)
                                .rotationEffect(.degrees(logoRotation))
                            
                            // App icon - using form-related icon to match the theme
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 50, weight: .medium))
                                .foregroundColor(.white)
                                .scaleEffect(isAnimating ? 1.1 : 0.8)
                                .animation(
                                    Animation.easeInOut(duration: 1.5)
                                        .repeatForever(autoreverses: true),
                                    value: isAnimating
                                )
                        }
                        
                        // App title with themed typography
                        VStack(spacing: AppTheme.Spacing.xs) {
                            Text("FormBuilder Express")
                                .font(AppTheme.Typography.largeTitle)
                                .foregroundColor(AppTheme.Colors.primaryText)
                                .opacity(isAnimating ? 1.0 : 0.0)
                                .animation(
                                    Animation.easeIn(duration: 1.0).delay(0.5),
                                    value: isAnimating
                                )
                            
                            Text("Building Forms Made Simple")
                                .font(AppTheme.Typography.body)
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .opacity(isAnimating ? 1.0 : 0.0)
                                .animation(
                                    Animation.easeIn(duration: 1.0).delay(1.0),
                                    value: isAnimating
                                )
                                .multilineTextAlignment(.center)
                        }
                        
                        // Feature highlights with icons
                        VStack(spacing: AppTheme.Spacing.sm) {
                            featureRow(icon: "shield.fill", text: "Secure & Protected", delay: 1.2)
                            featureRow(icon: "speedometer", text: "Fast & Reliable", delay: 1.4)
                            featureRow(icon: "hand.raised.fill", text: "Easy to Use", delay: 1.6)
                        }
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(
                            Animation.easeIn(duration: 0.8).delay(1.5),
                            value: isAnimating
                        )
                    }
                    
                    Spacer()
                    
                    // Loading indicator using themed component
                    VStack(spacing: AppTheme.Spacing.md) {
                        ThemedLoadingIndicator(count: 3)
                        
                        Text("Loading your experience...")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                            .opacity(isAnimating ? 0.8 : 0.0)
                            .animation(
                                Animation.easeIn(duration: 1.0).delay(2.0),
                                value: isAnimating
                            )
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            // Start animations with a sequence
            withAnimation(.easeOut(duration: 0.8)) {
                logoScale = 1.0
            }
            
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                logoRotation = 360
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = true
            }
            
            // Auto-dismiss after showing content
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                withAnimation(.easeOut(duration: 0.8)) {
                    showSplashScreen = false
                }
            }
        }
    }
    
    // Helper view for feature rows
    private func featureRow(icon: String, text: String, delay: Double) -> some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.Colors.iconBlue)
                .frame(width: 20)
            
            Text(text)
                .font(AppTheme.Typography.bodySmall)
                .foregroundColor(AppTheme.Colors.secondaryText)
            
            Spacer()
        }
        .opacity(isAnimating ? 1.0 : 0.0)
        .animation(
            Animation.easeIn(duration: 0.6).delay(delay),
            value: isAnimating
        )
    }
}

#Preview {
    SplashScreenView(showSplashScreen: .constant(true))
}