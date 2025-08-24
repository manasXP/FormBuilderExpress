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
    @FocusState private var focusedField: Field?
    
    enum Field: CaseIterable {
        case firstName, middleName, lastName, email, phone
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            // Personal Information Section
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                Text("Personal Information")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .accessibleFormSection(
                        header: "Personal Information Section",
                        description: "Enter nominee's personal details including name and date of birth"
                    )
                
                VStack(spacing: AppTheme.Spacing.md) {
                    ThemedInputField(
                        title: "First Name",
                        placeholder: "Enter nominee's first name",
                        text: $viewModel.nominee.name.first,
                        iconName: "person.fill",
                        isRequired: true
                    )
                    .focused($focusedField, equals: .firstName)
                    .onChange(of: viewModel.nominee.name.first) { _, newValue in
                        if newValue.count > FormValidationConstants.standardFieldMaxLength {
                            viewModel.nominee.name.first = String(newValue.prefix(FormValidationConstants.standardFieldMaxLength))
                        }
                    }
                    
                    ThemedInputField(
                        title: "Middle Name",
                        placeholder: "Enter nominee's middle name (optional)",
                        text: $viewModel.nominee.name.middle,
                        iconName: "person.fill",
                        isRequired: false
                    )
                    .focused($focusedField, equals: .middleName)
                    .onChange(of: viewModel.nominee.name.middle) { _, newValue in
                        if newValue.count > FormValidationConstants.standardFieldMaxLength {
                            viewModel.nominee.name.middle = String(newValue.prefix(FormValidationConstants.standardFieldMaxLength))
                        }
                    }
                    
                    ThemedInputField(
                        title: "Last Name",
                        placeholder: "Enter nominee's last name",
                        text: $viewModel.nominee.name.last,
                        iconName: "person.fill",
                        isRequired: true
                    )
                    .focused($focusedField, equals: .lastName)
                    .onChange(of: viewModel.nominee.name.last) { _, newValue in
                        if newValue.count > FormValidationConstants.standardFieldMaxLength {
                            viewModel.nominee.name.last = String(newValue.prefix(FormValidationConstants.standardFieldMaxLength))
                        }
                    }
                    
                    // Date Picker with themed styling
                    HStack {
                        HStack {
                            Text("Date of Birth")
                                .font(AppTheme.Typography.fieldLabel)
                                .foregroundColor(AppTheme.Colors.placeholderText)
                            
                            Text("*")
                                .font(AppTheme.Typography.fieldLabel)
                                .foregroundColor(AppTheme.Colors.errorColor)
                        }
                        
                        Spacer()
                        
                        DatePicker(
                            "",
                            selection: $viewModel.nominee.birthDate,
                            in: ...Date(),
                            displayedComponents: [.date]
                        )
                        .labelsHidden()
                        .accentColor(AppTheme.Colors.iconBlue)
                        .accessibilityLabel("Date of Birth")
                        .accessibilityHint("Select nominee's date of birth")
                    }
            
                    
                    // Age validation message
                    if let ageMessage = viewModel.ageValidationMessage(for: viewModel.nominee.birthDate, personType: "Nominee") {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(AppTheme.Colors.errorColor)
                            Text(ageMessage)
                                .foregroundColor(AppTheme.Colors.errorColor)
                                .font(AppTheme.Typography.caption)
                        }
                        .themedErrorMessage()
                    } else {
                        let age = viewModel.getAge(from: viewModel.nominee.birthDate)
                        if age >= FormValidationConstants.minimumAge {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(AppTheme.Colors.successColor)
                                Text("Age: \(age) years (valid)")
                                    .foregroundColor(AppTheme.Colors.successColor)
                                    .font(AppTheme.Typography.caption)
                            }
                        }
                    }
                }
            }
            
            // Contact Information Section
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                Text("Contact Information")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .accessibleFormSection(
                        header: "Contact Information Section",
                        description: "Enter nominee's email and phone number for communication"
                    )
                
                VStack(spacing: AppTheme.Spacing.md) {
                    ThemedInputField(
                        title: "Email Address",
                        placeholder: "Enter nominee's email address",
                        text: $viewModel.nominee.email,
                        iconName: "envelope.fill",
                        isRequired: true
                    )
                    .onChange(of: viewModel.nominee.email) { _, newValue in
                        if newValue.count > FormValidationConstants.standardFieldMaxLength {
                            viewModel.nominee.email = String(newValue.prefix(FormValidationConstants.standardFieldMaxLength))
                        }
                    }
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    
                    // Phone number field with themed styling
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        HStack {
                            Text("Phone Number")
                                .font(AppTheme.Typography.fieldLabel)
                                .foregroundColor(AppTheme.Colors.placeholderText)
                            
                            Text("*")
                                .font(AppTheme.Typography.fieldLabel)
                                .foregroundColor(AppTheme.Colors.errorColor)
                        }
                        
                        iPhoneNumberField("(000) 000-0000", text: $viewModel.nominee.phone, isEditing: $isEditing)
                            .flagHidden(false)
                            .flagSelectable(true)
                            .font(UIFont(size: 16, weight: .medium, design: .default))
                            .maximumDigits(10)
                            .foregroundColor(Color.primary)
                            .clearButtonMode(.whileEditing)
                            .onClear { _ in isEditing.toggle() }
                            .accentColor(AppTheme.Colors.iconBlue)
                            .focused($focusedField, equals: .phone)
                            .themedTextField()
                            .accessibilityLabel("Phone Number")
                            .accessibilityHint("Enter nominee's phone number with area code")
                    }
                }
            }
            
            // Validation indicator
            if viewModel.isNomineeInfoValid {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.successColor)
                    Text("Nominee information is complete")
                        .foregroundColor(AppTheme.Colors.successColor)
                        .font(AppTheme.Typography.bodySmall)
                }
                .padding(AppTheme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .fill(AppTheme.Colors.successColor.opacity(0.1))
                )
            }
        }
        .padding(AppTheme.Spacing.xl)
    }
}

#Preview {
    Form {
        NomineeInfoView()
    }
    .environmentObject(KYCFormViewModel())
}
