
//
//  SummaryView.swift
//  FormBuilderExpress
//
//  Created by Manas Pradhan on 09/07/25.
//

import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var viewModel: KYCFormViewModel
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        Section("Member Summary") {
            LabeledContent("Member Id", value: viewModel.member.memberId)
            LabeledContent("Full Name", value: viewModel.member.name.fullName)
            LabeledContent("Birth Date", value: dateFormatter.string(from: viewModel.member.birthDate))
            LabeledContent("Email", value: viewModel.member.email)
            LabeledContent("Phone", value: viewModel.member.phone)
        }
        
        Section("Member Address") {
            LabeledContent("Address", value: "\(viewModel.memberAddress.addressLine1), \(viewModel.memberAddress.city), \(viewModel.memberAddress.state) \(viewModel.memberAddress.zipCode)")
            LabeledContent("Country", value: viewModel.memberAddress.selectedCountry)
        }

        Section("Nominee Summary") {
            LabeledContent("Full Name", value: viewModel.nominee.name.fullName)
            LabeledContent("Birth Date", value: dateFormatter.string(from: viewModel.nominee.birthDate))
            LabeledContent("Email", value: viewModel.nominee.email)
            LabeledContent("Phone", value: viewModel.nominee.phone)
        }
        
        Section("Nominee Address") {
            LabeledContent("Address", value: "\(viewModel.nomineeAddress.addressLine1), \(viewModel.nomineeAddress.city), \(viewModel.nomineeAddress.state) \(viewModel.nomineeAddress.zipCode)")
            LabeledContent("Country", value: viewModel.nomineeAddress.selectedCountry)
        }
        
        Section("Bank Account Details") {
            LabeledContent("Account Holder", value: viewModel.account.accountHolderName)
            LabeledContent("Bank Name", value: viewModel.account.bankName)
            LabeledContent("Account Type", value: viewModel.account.accountType.rawValue)
            LabeledContent("Account Number", value: "****\(String(viewModel.account.accountNumber.suffix(4)))")
            LabeledContent("Routing Number", value: viewModel.account.routingNumber)
        }
        
        SignatureView()
    }
}

#Preview {
    Form {
        SummaryView()
    }
}
