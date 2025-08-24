//
//  FormView.swift
//  FormBuilderExpress
//
//  Created by Manas Pradhan on 07/07/25.
//

import SwiftUI

struct KYCFormView: View {
    @EnvironmentObject var viewModel: KYCFormViewModel
    @State private var isMenuOpen = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Apply themed background
                AppTheme.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                // Background blur effects
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
                
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        KYCProgressIndicatorView(
                            currentStep: viewModel.currentStep,
                            lastAutoSaved: viewModel.lastAutoSaved
                        )
                        
                        VStack {
                            KYCFormContentView()
                        }
                        .themedCard()
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        
                        KYCNavigationButtonsView(
                            onPrevious: tappedPrevious,
                            onNext: tappedNext,
                            onSubmit: tappedSubmit
                        )
                        .padding(.horizontal, AppTheme.Spacing.lg)
                    }
                    .padding(.vertical, AppTheme.Spacing.lg)
                }
                
                // Menu overlay (only the sliding menu, not the button)
                if isMenuOpen {
                    HamburgerMenuOverlay(isMenuOpen: $isMenuOpen)
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Member KYC Form")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.primaryText)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isMenuOpen.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.primaryText)
                    }
                }
            }
        }
    }
    
    func tappedPrevious() {
        viewModel.currentStep = viewModel.currentStep.previousView()
        print("Tapped Previous \(viewModel.currentStep.rawValue)")
    }
    
    func tappedNext() {
        guard viewModel.canProceedToNext() else { return }
        viewModel.currentStep = viewModel.currentStep.nextView()
        print("Tapped Next \(viewModel.currentStep.rawValue)")
    }

    func tappedSubmit() {
        Task {
            await viewModel.submitForm()
            // Clear draft after successful submission
            if viewModel.errorMessage == nil {
                viewModel.clearDraft()
            }
        }
        print("Tapped Submit - form submitted")
    }
}

#Preview {
    KYCFormView()
        .environmentObject(KYCFormViewModel())
        .environmentObject(AuthViewModel())
}
