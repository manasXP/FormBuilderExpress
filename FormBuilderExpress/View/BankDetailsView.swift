//
//  BankDetailsView.swift
//  FormBuilderExpress
//
//  Created by Manas Pradhan on 10/07/25.
//

import SwiftUI

struct BankAccountDetailsView: View {
    @EnvironmentObject var viewModel: KYCFormViewModel
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Holder Information")) {
                    TextField("Full Name", text: $viewModel.account.accountHolderName)
                        .textContentType(.name)
                        .autocapitalization(.words)
                        .onChange(of: viewModel.account.accountHolderName) { _, newValue in
                            if newValue.count > FormValidationConstants.standardFieldMaxLength {
                                viewModel.account.accountHolderName = String(newValue.prefix(FormValidationConstants.standardFieldMaxLength))
                            }
                        }
                }
                
                Section(header: Text("Bank Information")) {
                    TextField("Bank Name", text: $viewModel.account.bankName)
                        .textContentType(.organizationName)
                        .autocapitalization(.words)
                        .onChange(of: viewModel.account.bankName) { _, newValue in
                            if newValue.count > FormValidationConstants.standardFieldMaxLength {
                                viewModel.account.bankName = String(newValue.prefix(FormValidationConstants.standardFieldMaxLength))
                            }
                        }
                    
                    TextField("Routing Number", text: $viewModel.account.routingNumber)
                        .keyboardType(.numberPad)
                        .textContentType(.none)
                        .onChange(of: viewModel.account.routingNumber) { _, newValue in
                            // Limit to 9 digits
                            if newValue.count > 9 {
                                viewModel.account.routingNumber = String(newValue.prefix(9))
                            }
                        }
                    
                    Picker("Account Type", selection: $viewModel.account.accountType) {
                        ForEach(AccountType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Account Details"),footer: Text("Your bank account information is encrypted and secure."))  {
                    TextField("Account Number", text: $viewModel.account.accountNumber)
                        .keyboardType(.numberPad)
                        .textContentType(.none)
                        .onChange(of: viewModel.account.accountNumber) { _, newValue in
                            // Limit to reasonable account number length
                            if newValue.count > 17 {
                                viewModel.account.accountNumber = String(newValue.prefix(17))
                            }
                        }
                    
                    TextField("Confirm Account Number", text: $viewModel.account.confirmAccountNumber)
                        .keyboardType(.numberPad)
                        .textContentType(.none)
                        .onChange(of: viewModel.account.confirmAccountNumber) { _, newValue in
                            if newValue.count > 17 {
                                viewModel.account.confirmAccountNumber = String(newValue.prefix(17))
                            }
                        }
                    
                    if !viewModel.account.confirmAccountNumber.isEmpty && viewModel.account.accountNumber != viewModel.account.confirmAccountNumber {
                        Text("Account numbers do not match")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                // Validation indicator
                if viewModel.isAccountValid {
                    Section {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Bank account information is complete")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("Bank Account")
            .navigationBarTitleDisplayMode(.large)
            .alert("Bank Account", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

#Preview {
    BankAccountDetailsView()
}
