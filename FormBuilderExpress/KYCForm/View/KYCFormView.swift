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
                Form {
                    KYCProgressIndicatorView(
                        currentStep: viewModel.currentStep,
                        lastAutoSaved: viewModel.lastAutoSaved
                    )
                    
                    KYCFormContentView()
                    
                    KYCNavigationButtonsView(
                        onPrevious: tappedPrevious,
                        onNext: tappedNext,
                        onSubmit: tappedSubmit
                    )
                }
                
                HamburgerMenuView(isMenuOpen: $isMenuOpen)
            }
            .navigationTitle("Member KYC Form")
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
