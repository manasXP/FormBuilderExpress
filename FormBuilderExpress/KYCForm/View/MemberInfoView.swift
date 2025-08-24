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
        VStack(spacing: AppTheme.Spacing.sm) {
            // Personal Information Section
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text("Personal Information")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .accessibleFormSection(
                        header: "Personal Information Section",
                        description: "Enter your personal details including name and date of birth"
                    )
                
                VStack(spacing: AppTheme.Spacing.md) {
                    ThemedInputField(
                        title: "First Name",
                        placeholder: "Enter your first name",
                        text: $viewModel.member.name.first,
                        iconName: "person.fill",
                        isRequired: true
                    )
                    .focused($focusedField, equals: .firstName)
                    .onChange(of: viewModel.member.name.first) { _, newValue in
                        if newValue.count > FormValidationConstants.standardFieldMaxLength {
                            viewModel.member.name.first = String(newValue.prefix(FormValidationConstants.standardFieldMaxLength))
                        }
                    }
                    
                    ThemedInputField(
                        title: "Middle Name",
                        placeholder: "Enter your middle name (optional)",
                        text: $viewModel.member.name.middle,
                        iconName: "person.fill",
                        isRequired: false
                    )
                    .focused($focusedField, equals: .middleName)
                    .onChange(of: viewModel.member.name.middle) { _, newValue in
                        if newValue.count > FormValidationConstants.standardFieldMaxLength {
                            viewModel.member.name.middle = String(newValue.prefix(FormValidationConstants.standardFieldMaxLength))
                        }
                    }
                    
                    ThemedInputField(
                        title: "Last Name",
                        placeholder: "Enter your last name",
                        text: $viewModel.member.name.last,
                        iconName: "person.fill",
                        isRequired: true
                    )
                    .focused($focusedField, equals: .lastName)
                    .onChange(of: viewModel.member.name.last) { _, newValue in
                        if newValue.count > FormValidationConstants.standardFieldMaxLength {
                            viewModel.member.name.last = String(newValue.prefix(FormValidationConstants.standardFieldMaxLength))
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
                            selection: $viewModel.member.birthDate,
                            in: ...Date(),
                            displayedComponents: [.date]
                        )
                        .labelsHidden()
                        .accentColor(AppTheme.Colors.iconBlue)
                        .accessibilityLabel("Date of Birth")
                        .accessibilityHint("Select your date of birth")
                    }
            
                    
                    // Age validation message
                    if let ageMessage = viewModel.ageValidationMessage(for: viewModel.member.birthDate, personType: "Member") {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(AppTheme.Colors.errorColor)
                            Text(ageMessage)
                                .foregroundColor(AppTheme.Colors.errorColor)
                                .font(AppTheme.Typography.caption)
                        }
                        .themedErrorMessage()
                    } else {
                        let age = viewModel.getAge(from: viewModel.member.birthDate)
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
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text("Contact Information")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .accessibleFormSection(
                        header: "Contact Information Section",
                        description: "Enter your email and phone number for communication"
                    )
                
                VStack(spacing: AppTheme.Spacing.sm) {
                    ThemedInputField(
                        title: "Email Address",
                        placeholder: "Enter your email address",
                        text: $viewModel.member.email,
                        iconName: "envelope.fill",
                        isRequired: true
                    )
                    .onChange(of: viewModel.member.email) { _, newValue in
                        if newValue.count > FormValidationConstants.standardFieldMaxLength {
                            viewModel.member.email = String(newValue.prefix(FormValidationConstants.standardFieldMaxLength))
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
                        
                        iPhoneNumberField("(000) 000-0000", text: $viewModel.member.phone, isEditing: $isEditing)
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
                            .accessibilityHint("Enter your phone number with area code")
                    }
                }
            }
            
            // Validation indicator
            if viewModel.isMemberInfoValid {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.successColor)
                    Text("Member information is complete")
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
        MemberInfoView()
    }
    .environmentObject(KYCFormViewModel())
}
