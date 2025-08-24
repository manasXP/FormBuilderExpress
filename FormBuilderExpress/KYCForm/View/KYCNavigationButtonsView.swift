//
//  KYCNavigationButtonsView.swift
//  FormBuilderExpress
//
//  Created by Manas Pradhan on 24/08/25.
//

import SwiftUI

struct KYCNavigationButtonsView: View {
    @EnvironmentObject var viewModel: KYCFormViewModel
    
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onSubmit: () -> Void
    
    var body: some View {
        if viewModel.currentStep == .summary {
            summaryNavigationButtons
        } else {
            standardNavigationButtons
        }
    }
    
    private var summaryNavigationButtons: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Button(action: onPrevious) {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "chevron.left")
                        .font(AppTheme.Typography.buttonTextSmall)
                    Text("Previous")
                        .font(AppTheme.Typography.buttonTextSmall)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.md)
            }
            .themedButton(isLoading: viewModel.isLoading, style: .secondary)
            .disabled(viewModel.isLoading)
            
            Button(action: onSubmit) {
                HStack(spacing: AppTheme.Spacing.xs) {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "checkmark")
                            .font(AppTheme.Typography.buttonTextSmall)
                    }
                    Text(viewModel.isLoading ? "Submitting..." : "Submit")
                        .font(AppTheme.Typography.buttonTextSmall)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.md)
            }
            .themedButton(isLoading: viewModel.isLoading, style: .primary)
            .disabled(viewModel.isLoading)
        }
    }
    
    private var standardNavigationButtons: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Button(action: onPrevious) {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "chevron.left")
                        .font(AppTheme.Typography.buttonTextSmall)
                    Text("Previous")
                        .font(AppTheme.Typography.buttonTextSmall)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.md)
            }
            .themedButton(
                isLoading: false, 
                style: viewModel.currentStep == .memberInfo ? .secondary : .primary
            )
            .disabled(viewModel.currentStep == .memberInfo)
            .opacity(viewModel.currentStep == .memberInfo ? 0.5 : 1.0)
            
            Button(action: onNext) {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Text("Next")
                        .font(AppTheme.Typography.buttonTextSmall)
                    Image(systemName: "chevron.right")
                        .font(AppTheme.Typography.buttonTextSmall)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.md)
            }
            .themedButton(
                isLoading: false,
                style: viewModel.canProceedToNext() ? .primary : .secondary
            )
            .disabled(!viewModel.canProceedToNext())
            .opacity(viewModel.canProceedToNext() ? 1.0 : 0.6)
        }
    }
}

#Preview {
    KYCNavigationButtonsView(
        onPrevious: {},
        onNext: {},
        onSubmit: {}
    )
    .environmentObject(KYCFormViewModel())
}