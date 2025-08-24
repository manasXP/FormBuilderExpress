//
//  AddressView.swift
//  FormBuilderExpress
//
//  Created by Manas Pradhan on 07/07/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct AddressView: View {
    @EnvironmentObject var viewModel: KYCFormViewModel
    @State private var isShowingFileImporter = false
    @State private var selectedFileURL: URL?
    @FocusState private var focusedField: Field?
    
    enum Field: CaseIterable {
        case addressLine1, addressLine2, city, state, zipCode
    }
    
    let countries = [
        "United States", "India", "Canada", "United Kingdom", "Australia", "Germany",
        "France", "Japan", "China", "Brazil", "UAE", "Singapore"
    ]
    
    // Determine which address to bind to based on current step
    private var addressBinding: Binding<Address> {
        switch viewModel.currentStep {
        case .memberAddress:
            return $viewModel.memberAddress
        case .nomineeAddress:
            return $viewModel.nomineeAddress
        default:
            return $viewModel.memberAddress // Fallback
        }
    }
    
    private var isValid: Bool {
        switch viewModel.currentStep {
        case .memberAddress:
            return viewModel.isMemberAddressValid
        case .nomineeAddress:
            return viewModel.isNomineeAddressValid
        default:
            return false
        }
    }
    
    private var headerTitle: String {
        switch viewModel.currentStep {
        case .memberAddress:
            return "Member Address Information"
        case .nomineeAddress:
            return "Nominee Address Information"
        default:
            return "Address Information"
        }
    }
    
    private var personType: String {
        switch viewModel.currentStep {
        case .memberAddress:
            return "member's"
        case .nomineeAddress:
            return "nominee's"
        default:
            return ""
        }
    }
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            // Address Information Section
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                Text("Address Information")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .accessibleFormSection(
                        header: "Address Information Section",
                        description: "Enter \(personType) address details"
                    )
                
                VStack(spacing: AppTheme.Spacing.md) {
                    ThemedInputField(
                        title: "Address Line 1",
                        placeholder: "Enter \(personType) address line 1",
                        text: addressBinding.addressLine1,
                        iconName: "house.fill",
                        isRequired: true
                    )
                    .focused($focusedField, equals: .addressLine1)
                    .onChange(of: addressBinding.wrappedValue.addressLine1) { _, newValue in
                        if newValue.count > FormValidationConstants.standardFieldMaxLength {
                            addressBinding.wrappedValue.addressLine1 = String(newValue.prefix(FormValidationConstants.standardFieldMaxLength))
                        }
                    }
                    
                    ThemedInputField(
                        title: "Address Line 2",
                        placeholder: "Enter \(personType) address line 2 (optional)",
                        text: addressBinding.addressLine2,
                        iconName: "house.fill",
                        isRequired: false
                    )
                    .focused($focusedField, equals: .addressLine2)
                    .onChange(of: addressBinding.wrappedValue.addressLine2) { _, newValue in
                        if newValue.count > FormValidationConstants.standardFieldMaxLength {
                            addressBinding.wrappedValue.addressLine2 = String(newValue.prefix(FormValidationConstants.standardFieldMaxLength))
                        }
                    }
                    
                    ThemedInputField(
                        title: "City",
                        placeholder: "Enter city",
                        text: addressBinding.city,
                        iconName: "building.2.fill",
                        isRequired: true
                    )
                    .focused($focusedField, equals: .city)
                    .onChange(of: addressBinding.wrappedValue.city) { _, newValue in
                        if newValue.count > FormValidationConstants.standardFieldMaxLength {
                            addressBinding.wrappedValue.city = String(newValue.prefix(FormValidationConstants.standardFieldMaxLength))
                        }
                    }
                    
                    ThemedInputField(
                        title: "State/Province",
                        placeholder: "Enter state or province",
                        text: addressBinding.state,
                        iconName: "map.fill",
                        isRequired: true
                    )
                    .focused($focusedField, equals: .state)
                    .onChange(of: addressBinding.wrappedValue.state) { _, newValue in
                        if newValue.count > FormValidationConstants.standardFieldMaxLength {
                            addressBinding.wrappedValue.state = String(newValue.prefix(FormValidationConstants.standardFieldMaxLength))
                        }
                    }
                    
                    ThemedInputField(
                        title: "ZIP/Postal Code",
                        placeholder: "Enter ZIP or postal code",
                        text: addressBinding.zipCode,
                        iconName: "envelope.fill",
                        isRequired: true
                    )
                    .focused($focusedField, equals: .zipCode)
                    .onChange(of: addressBinding.wrappedValue.zipCode) { _, newValue in
                        if newValue.count > 6 {
                            addressBinding.wrappedValue.zipCode = String(newValue.prefix(6))
                        }
                    }
                    
                    // Country Picker with themed styling
                    HStack {
                        HStack {
                            Text("Country")
                                .font(AppTheme.Typography.fieldLabel)
                                .foregroundColor(AppTheme.Colors.placeholderText)
                            
                            Text("*")
                                .font(AppTheme.Typography.fieldLabel)
                                .foregroundColor(AppTheme.Colors.errorColor)
                        }
                        
                        Spacer()
                        
                        Picker("Select Country", selection: addressBinding.selectedCountry) {
                            ForEach(countries, id: \.self) { country in
                                Text(country)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .accentColor(AppTheme.Colors.iconBlue)
                        .accessibilityLabel("Country")
                        .accessibilityHint("Select country")
                    }
                }
            }
            
            // Supporting Documents Section
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                Text("Supporting Documents")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .accessibleFormSection(
                        header: "Supporting Documents Section",
                        description: "Upload supporting documents for address verification"
                    )
                
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    HStack {
                        Button("Select File") {
                            isShowingFileImporter = true
                        }
                        .buttonStyle(.bordered)
                        .accentColor(AppTheme.Colors.iconBlue)
                        .fileImporter(
                            isPresented: $isShowingFileImporter,
                            allowedContentTypes: [.pdf, .image],
                            allowsMultipleSelection: true
                        ) { result in
                            switch result {
                            case .success(let fileURLs):
                                selectedFileURL = fileURLs.first
                            case .failure(let error):
                                print("Error selecting file: \(error)")
                            }
                        }
                        
                        Spacer()
                    }
                    
                    if let selectedFileURL = selectedFileURL {
                        HStack {
                            Image(systemName: "doc.fill")
                                .foregroundColor(AppTheme.Colors.iconBlue)
                            Text("Selected: \(selectedFileURL.lastPathComponent)")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.primaryText)
                            
                            Spacer()
                        }
                        .padding(AppTheme.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                                .fill(AppTheme.Colors.iconBlue.opacity(0.1))
                        )
                    }
                }
            }
            
            // Validation indicator
            if isValid {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.successColor)
                    Text("Address information is complete")
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
        NavigationStack {
            Form {
                AddressView()
            }
        }
}
