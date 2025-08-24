//
//  KYCFormContentView.swift
//  FormBuilderExpress
//
//  Created by Manas Pradhan on 24/08/25.
//

import SwiftUI

struct KYCFormContentView: View {
    @EnvironmentObject var viewModel: KYCFormViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            currentStepView
            
            if viewModel.isLoading {
                loadingIndicator
            }
            
            if let errorMessage = viewModel.errorMessage {
                errorMessageView(errorMessage)
            }
        }
    }
    
    @ViewBuilder
    private var currentStepView: some View {
        switch viewModel.currentStep {
        case .memberInfo:
            MemberInfoView()
        case .memberAddress:
            AddressView()
        case .nomineeInfo:
            NomineeInfoView()
        case .nomineeAddress:
            AddressView()
        case .memberBankDetails:
            BankAccountDetailsView()
        case .summary:
            SummaryView()
        }
    }
    
    private var loadingIndicator: some View {
        Section {
            HStack {
                ProgressView()
                Text("Submitting form...")
            }
        }
    }
    
    private func errorMessageView(_ message: String) -> some View {
        Section {
            Text(message)
                .foregroundColor(.red)
        }
    }
}

#Preview {
    KYCFormContentView()
        .environmentObject(KYCFormViewModel())
}