//
//  PersonModel.swift
//  FormBuilderExpress
//
//  Created by Manas Pradhan on 09/07/25.
//
import Foundation
import FirebaseFirestore

struct Person: Codable {
    @DocumentID var id: String?
    var memberId: String = "manaspr"
    var name: Name = Name(first: "", middle: "", last: "")
    var email: String = ""
    var phone: String = ""
    var birthDate = Date()
    var address = Address()
}

struct Name: Codable {
    var first: String
    var middle: String
    var last: String
    
    var fullName: String {
        return "\(first) \(middle) \(last)"
    }
}

struct Address: Codable {
    var selectedCountry: String = "United States"
    var addressLine1: String = ""
    var addressLine2: String = ""
    var city: String = ""
    var state: String = ""
    var zipCode: String = ""
}

struct DigitalSignature: Codable {
    var imageData: Data?
    var timestamp: Date = Date()
    var isComplete: Bool = false
    var userId: String = ""
}

