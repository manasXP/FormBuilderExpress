//
//  AuthModel.swift
//  FormBuilderExpress
//
//  Created by Manas Pradhan on 10/07/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

// MARK: - AuthModel
struct AuthModel {
    @DocumentID var id: String?
    let uid: String
    let email: String?
    let phoneNumber: String?
    let displayName: String?
    let isEmailVerified: Bool
    
    init(from user: User) {
        self.id = user.uid
        self.uid = user.uid
        self.email = user.email
        self.phoneNumber = user.phoneNumber
        self.displayName = user.displayName
        self.isEmailVerified = user.isEmailVerified
    }
}
