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
            TextField("Middle Name", text: $viewModel.nominee.name.middle)
            TextField("Last Name", text: $viewModel.nominee.name.last)
            DatePicker(
                "Birthdate",
                selection: $viewModel.nominee.birthDate,
                displayedComponents: [.date]
            )
        }
        
        Section("Nominee Contact Information") {
            TextField("Email", text: $viewModel.nominee.email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
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
}
