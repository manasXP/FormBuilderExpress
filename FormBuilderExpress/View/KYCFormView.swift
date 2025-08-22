//
//  FormView.swift
//  FormBuilderExpress
//
//  Created by Manas Pradhan on 07/07/25.
//

import SwiftUI

enum DataView: String, CaseIterable, Codable {
    case memberInfo
    case memberAddress
    case nomineeInfo
    case nomineeAddress
    case memberBankDetails
    case summary
    
    func nextView() -> DataView {
        switch self {
        case .memberInfo: return .memberAddress
        case .memberAddress: return .nomineeInfo
        case .nomineeInfo: return .nomineeAddress
        case .nomineeAddress: return .memberBankDetails
        case .memberBankDetails: return .summary
        case .summary: return .memberInfo
        }
    }
    
    func previousView() -> DataView {
        switch self {
            case .memberInfo: return .summary
            case .memberAddress: return .memberInfo
            case .nomineeInfo: return .memberAddress
            case .nomineeAddress: return .nomineeInfo
            case .memberBankDetails:return .nomineeAddress
            case .summary: return .memberBankDetails
        }
    }
}

struct KYCFormView: View {
    @EnvironmentObject var viewModel: KYCFormViewModel
    
    // Computed properties for progress tracking
    private var stepNumber: Int {
        switch viewModel.currentStep {
        case .memberInfo: return 1
        case .memberAddress: return 2
        case .nomineeInfo: return 3
        case .nomineeAddress: return 4
        case .memberBankDetails: return 5
        case .summary: return 6
        }
    }
    
    private var stepTitle: String {
        switch viewModel.currentStep {
        case .memberInfo: return "Member Information"
        case .memberAddress: return "Member Address"
        case .nomineeInfo: return "Nominee Information"
        case .nomineeAddress: return "Nominee Address"
        case .memberBankDetails: return "Bank Details"
        case .summary: return "Review & Submit"
        }
    }
    
    private var progressValue: Double {
        Double(stepNumber) / 6.0
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Progress indicator
                ProgressView(value: progressValue, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .padding(.vertical)
                
                HStack {
                    Text("Step \(stepNumber) of 6: \(stepTitle)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let lastSaved = viewModel.lastAutoSaved {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption2)
                            Text("Saved \(timeAgoSince(lastSaved))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Show the Data View screen which user is currently filling in
                switch (viewModel.currentStep) {
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

                // Loading indicator
                if viewModel.isLoading {
                    Section {
                        HStack {
                            ProgressView()
                            Text("Submitting form...")
                        }
                    }
                }
                
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }

                // Navigation buttons
                if viewModel.currentStep == .summary {
                    HStack {
                        Button(action: tappedPrevious) {
                            Text("Previous")
                                .frame(maxWidth: 80)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                        .disabled(viewModel.isLoading)
                        
                        Spacer()
                        
                        Button(action: tappedSubmit) {
                            Text("Submit")
                                .frame(maxWidth: 80)
                                .padding()
                                .foregroundColor(.white)
                                .background(viewModel.isLoading ? Color.gray : Color.green)
                                .cornerRadius(8)
                        }
                        .disabled(viewModel.isLoading)
                    }
                } else {
                    HStack {
                        Button(action: tappedPrevious) {
                            Text("Previous")
                                .frame(maxWidth: 80)
                                .padding()
                                .foregroundColor(.white)
                                .background(viewModel.currentStep == .memberInfo ? Color.gray : Color.green)
                                .cornerRadius(8)
                        }
                        .disabled(viewModel.currentStep == .memberInfo)
                        
                        Spacer()
                        
                        Button(action: tappedNext) {
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
    
    private func timeAgoSince(_ date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 60 {
            return "now"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)m ago"
        } else {
            let hours = Int(timeInterval / 3600)
            return "\(hours)h ago"
        }
    }
}

#Preview {
    KYCFormView()
}
