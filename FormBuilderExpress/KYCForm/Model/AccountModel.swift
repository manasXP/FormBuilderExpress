//
//  AccountModel.swift
//  FormBuilderExpress
//
//  Created by Manas Pradhan on 10/07/25.
//

import Foundation
import FirebaseFirestore

struct Account: Codable {
    @DocumentID var id: String?
    var accountHolderName: String = ""
    var accountNumber: String = ""
    var routingNumber = ""
    var bankName = ""
    var accountType = AccountType.savings
    var confirmAccountNumber = ""
}


enum AccountType: String, Codable, CaseIterable {
    case checking = "Checking"
    case savings = "Savings"
    case current = "Current"
    case businessChecking = "Business Checking"
    case businessSavings = "Business Savings"
}
