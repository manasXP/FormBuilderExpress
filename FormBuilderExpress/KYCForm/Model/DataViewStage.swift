//
//  DataViewStage.swift
//  FormBuilderExpress
//
//  Created by Manas Pradhan on 24/08/25.
//

import Foundation

enum DataViewStage: String, CaseIterable, Codable {
    case memberInfo
    case memberAddress
    case nomineeInfo
    case nomineeAddress
    case memberBankDetails
    case summary
    
    func nextView() -> DataViewStage {
        switch self {
        case .memberInfo: return .memberAddress
        case .memberAddress: return .nomineeInfo
        case .nomineeInfo: return .nomineeAddress
        case .nomineeAddress: return .memberBankDetails
        case .memberBankDetails: return .summary
        case .summary: return .memberInfo
        }
    }
    
    func previousView() -> DataViewStage {
        switch self {
            case .memberInfo: return .summary
            case .memberAddress: return .memberInfo
            case .nomineeInfo: return .memberAddress
            case .nomineeAddress: return .nomineeInfo
            case .memberBankDetails:return .nomineeAddress
            case .summary: return .memberBankDetails
        }
    }
}