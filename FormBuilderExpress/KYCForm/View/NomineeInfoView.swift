//
//  NomineeInfoView.swift
//  FormBuilderExpress
//
//  Created by Manas Pradhan on 09/07/25.
//

import SwiftUI
import iPhoneNumberField

struct NomineeInfoView: View {
    @EnvironmentObject var viewModel: KYCFormViewModel
    @State private var isEditing: Bool = false

    var body: some View {
        Section("Nominee Personal Information") {
            TextField("First Name", text: $viewModel.nominee.name.first)
                .onChange(of: viewModel.nominee.name.first) { _, newValue in
                    if newValue.count > FormValidationConstants.standardFieldMaxLength {
                        viewModel.nominee.name.first = String(newValue.prefix(FormValidationConstants.standardFieldMaxLength))
                    }
                }
            TextField("Middle Name", text: $viewModel.nominee.name.middle)
                .onChange(of: viewModel.nominee.name.middle) { _, newValue in
                    if newValue.count > FormValidationConstants.standardFieldMaxLength {
                        viewModel.nominee.name.middle = String(newValue.prefix(FormValidationConstants.standardFieldMaxLength))
                    }
                }
            TextField("Last Name", text: $viewModel.nominee.name.last)
                .onChange(of: viewModel.nominee.name.last) { _, newValue in
                    if newValue.count > FormValidationConstants.standardFieldMaxLength {
                        viewModel.nominee.name.last = String(newValue.prefix(FormValidationConstants.standardFieldMaxLength))
                    }
                }
            DatePicker(
                "Birthdate",
                selection: $viewModel.nominee.birthDate,
                in: ...Date(),
                displayedComponents: [.date]
            )
            
            // Age validation message
            if let ageMessage = viewModel.ageValidationMessage(for: viewModel.nominee.birthDate, personType: "Nominee") {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(ageMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                .padding(.top, 4)
            } else {
                let age = viewModel.getAge(from: viewModel.nominee.birthDate)
                if age >= FormValidationConstants.minimumAge {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Age: \(age) years (valid)")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    .padding(.top, 4)
                }
            }
        }
        
        Section("Nominee Contact Information") {
            TextField("Email", text: $viewModel.nominee.email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .onChange(of: viewModel.nominee.email) { _, newValue in
                    if newValue.count > FormValidationConstants.standardFieldMaxLength {
                        viewModel.nominee.email = String(newValue.prefix(FormValidationConstants.standardFieldMaxLength))
                    }
                }
                .padding()
            iPhoneNumberField("(000) 000-0000", text: $viewModel.nominee.phone, isEditing: $isEditing)
                .flagHidden(false)
                .flagSelectable(true)
                .font(UIFont(size: 18, weight: .light, design: .monospaced))
                .maximumDigits(10)
                .foregroundColor(Color.pink)
                .clearButtonMode(.whileEditing)
                .onClear { _ in isEditing.toggle() }
                .accentColor(Color.orange)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: isEditing ? .gray : .white, radius: 10)
        }
        
        // Validation indicator
        if viewModel.isNomineeInfoValid {
            Section {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Nominee information is complete")
                        .foregroundColor(.green)
                }
            }
        }
    }
}

#Preview {
    Form {
        NomineeInfoView()
    }
    .environmentObject(KYCFormViewModel())
}
