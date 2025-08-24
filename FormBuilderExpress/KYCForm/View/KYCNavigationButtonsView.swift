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
        HStack {
            Button(action: onPrevious) {
                Text("Previous")
                    .frame(maxWidth: 80)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(8)
            }
            .disabled(viewModel.isLoading)
            
            Spacer()
            
            Button(action: onSubmit) {
                Text("Submit")
                    .frame(maxWidth: 80)
                    .padding()
                    .foregroundColor(.white)
                    .background(viewModel.isLoading ? Color.gray : Color.green)
                    .cornerRadius(8)
            }
            .disabled(viewModel.isLoading)
        }
    }
    
    private var standardNavigationButtons: some View {
        HStack {
            Button(action: onPrevious) {
                Text("Previous")
                    .frame(maxWidth: 80)
                    .padding()
                    .foregroundColor(.white)
                    .background(viewModel.currentStep == .memberInfo ? Color.gray : Color.green)
                    .cornerRadius(8)
            }
            .disabled(viewModel.currentStep == .memberInfo)
            
            Spacer()
            
            Button(action: onNext) {
                Text("Next")
                    .frame(maxWidth: 80)
                    .padding()
                    .foregroundColor(.white)
                    .background(viewModel.canProceedToNext() ? Color.green : Color.gray)
                    .cornerRadius(8)
            }
            .disabled(!viewModel.canProceedToNext())
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