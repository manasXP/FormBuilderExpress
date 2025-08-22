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
            return "Member Address"
        case .nomineeAddress:
            return "Nominee Address"
        default:
            return "Address"
        }
    }
    
    var body: some View {
        Section(header: Text(headerTitle)) {
            TextField("Address Line 1", text: addressBinding.addressLine1)
            TextField("Address Line 2 (Optional)", text: addressBinding.addressLine2)
            TextField("City", text: addressBinding.city)
            TextField("State/Province", text: addressBinding.state)
            TextField("ZIP/Postal Code", text: addressBinding.zipCode)
            Picker("Select Country", selection: addressBinding.selectedCountry) {
                ForEach(countries, id: \.self) { country in
                    Text(country)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
        
        Section(header: Text("Supporting Documents")) {
            Button("Select File") {
                isShowingFileImporter = true
            }
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
            
            if let selectedFileURL = selectedFileURL {
                Text("Selected: \(selectedFileURL.lastPathComponent)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        
        // Validation indicator
        if isValid {
            Section {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Address information is complete")
                        .foregroundColor(.green)
                }
            }
        }
    }
}

#Preview {
        NavigationStack {
            Form {
                AddressView()
            }
        }
}
