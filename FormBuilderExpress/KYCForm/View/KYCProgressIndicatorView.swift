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
        VStack(spacing: AppTheme.Spacing.sm) {
            // Progress bar with themed styling
            ProgressView(value: progressValue, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: AppTheme.Colors.iconBlue))
                .scaleEffect(y: 2.0) // Make progress bar thicker
                .animation(.easeInOut(duration: 0.3), value: progressValue)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Step \(stepNumber) of 6")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.primaryText)
                        .fontWeight(.semibold)
                    
                    Text(stepTitle)
                        .font(AppTheme.Typography.bodySmall)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
                
                Spacer()
                
                if let lastSaved = lastAutoSaved {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.successColor)
                            .font(AppTheme.Typography.caption)
                        
                        Text("Saved \(timeAgoSince(lastSaved))")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.secondaryText)
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