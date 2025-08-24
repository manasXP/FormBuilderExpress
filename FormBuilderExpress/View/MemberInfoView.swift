//
//  MemberInfoView.swift
//  FormBuilderExpress
//
//  Created by Manas Pradhan on 09/07/25.
//

import SwiftUI
import iPhoneNumberField

struct MemberInfoView: View {
    @EnvironmentObject var viewModel: KYCFormViewModel
    @State private var isEditing: Bool = false
    @FocusState private var focusedField: Field?
    
    enum Field: CaseIterable {
        case firstName, middleName, lastName, email, phone
    }

    var body: some View {
        Section {
            TextField("First Name", text: $viewModel.member.name.first)
                .focused($focusedField, equals: .firstName)
                .onChange(of: viewModel.member.name.first) { _, newValue in
                    if newValue.count > FormValidationConstants.standardFieldMaxLength {
                        viewModel.member.name.first = String(newValue.prefix(FormValidationConstants.standardFieldMaxLength))
                    }
                }
                .accessibleFormField(
                    label: "First Name",
                    hint: "Enter your first name",
                    isRequired: true
                )
                .scaledFont(.body, maxSize: 24)
                .highContrastAdaptive()
                
            TextField("Middle Name", text: $viewModel.member.name.middle)
                .focused($focusedField, equals: .middleName)
                .onChange(of: viewModel.member.name.middle) { _, newValue in
                    if newValue.count > FormValidationConstants.standardFieldMaxLength {
                        viewModel.member.name.middle = String(newValue.prefix(FormValidationConstants.standardFieldMaxLength))
                    }
                }
                .accessibleFormField(
                    label: "Middle Name",
                    hint: "Enter your middle name, optional",
                    isRequired: false
                )
                .scaledFont(.body, maxSize: 24)
                .highContrastAdaptive()
                
            TextField("Last Name", text: $viewModel.member.name.last)
                .focused($focusedField, equals: .lastName)
                .onChange(of: viewModel.member.name.last) { _, newValue in
                    if newValue.count > FormValidationConstants.standardFieldMaxLength {
                        viewModel.member.name.last = String(newValue.prefix(FormValidationConstants.standardFieldMaxLength))
                    }
                }
                .accessibleFormField(
                    label: "Last Name",
                    hint: "Enter your last name",
                    isRequired: true
                )
                .scaledFont(.body, maxSize: 24)
                .highContrastAdaptive()
                
            DatePicker(
                "Birthdate",
                selection: $viewModel.member.birthDate,
                displayedComponents: [.date]
            )
            .accessibilityLabel("Date of Birth")
            .accessibilityHint("Select your date of birth")
            .scaledFont(.body, maxSize: 24)
            .highContrastAdaptive()
        } header: {
            Text("Personal Information")
                .scaledFont(.headline, maxSize: 28)
                .highContrastAdaptive()
        }
        .accessibleFormSection(
            header: "Personal Information Section",
            description: "Enter your personal details including name and date of birth"
        )
        
        Section {
            TextField("Email", text: $viewModel.member.email)
                .focused($focusedField, equals: .email)
                .onChange(of: viewModel.member.email) { _, newValue in
                    if newValue.count > FormValidationConstants.standardFieldMaxLength {
                        viewModel.member.email = String(newValue.prefix(FormValidationConstants.standardFieldMaxLength))
                    }
                }
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .accessibleFormField(
                    label: "Email Address",
                    hint: "Enter your email address for communication",
                    isRequired: true
                )
                .scaledFont(.body, maxSize: 24)
                .highContrastAdaptive()
                .padding()
                
            iPhoneNumberField("(000) 000-0000", text: $viewModel.member.phone, isEditing: $isEditing)
                .flagHidden(false)
                .flagSelectable(true)
                .font(UIFont(size: 18, weight: .light, design: .monospaced))
                .maximumDigits(10)
                .foregroundColor(Color.pink)
                .clearButtonMode(.whileEditing)
                .onClear { _ in isEditing.toggle() }
                .accentColor(Color.orange)
                .focused($focusedField, equals: .phone)
                .accessibilityLabel("Phone Number")
                .accessibilityHint("Enter your phone number with area code")
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .shadow(color: isEditing ? Color.gray : Color.clear, radius: 10)
        } header: {
            Text("Contact Information")
                .scaledFont(.headline, maxSize: 28)
                .highContrastAdaptive()
        }
        .accessibleFormSection(
            header: "Contact Information Section",
            description: "Enter your email and phone number for communication"
        )
        
        // Validation indicator
        if viewModel.isMemberInfoValid {
            Section {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Member information is complete")
                        .foregroundColor(.green)
                }
            }
        }
    }
}

#Preview {
    Form {
        MemberInfoView()
    }
}
