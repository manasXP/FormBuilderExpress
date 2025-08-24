//
//  KYCProgressIndicatorView.swift
//  FormBuilderExpress
//
//  Created by Manas Pradhan on 24/08/25.
//

import SwiftUI

struct KYCProgressIndicatorView: View {
    let currentStep: DataViewStage
    let lastAutoSaved: Date?
    
    private var stepNumber: Int {
        switch currentStep {
        case .memberInfo: return 1
        case .memberAddress: return 2
        case .nomineeInfo: return 3
        case .nomineeAddress: return 4
        case .memberBankDetails: return 5
        case .summary: return 6
        }
    }
    
    private var stepTitle: String {
        switch currentStep {
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
        VStack(spacing: 8) {
            ProgressView(value: progressValue, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .padding(.vertical)
            
            HStack {
                Text("Step \(stepNumber) of 6: \(stepTitle)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let lastSaved = lastAutoSaved {
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
        }
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
    KYCProgressIndicatorView(
        currentStep: .memberInfo,
        lastAutoSaved: Date()
    )
}