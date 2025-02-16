//
//  Utils.swift
//  UpVPN
//
//  Created by Himanshu on 7/17/24.
//

import Foundation

func bundleIdentifireWithoutNE() -> String {
    var bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
    if bundleIdentifier.hasSuffix(".network-extension") {
        bundleIdentifier.removeLast(".network-extension".count)
    }

    return bundleIdentifier
}

func encodeToData<T: Encodable>(_ value: T) -> Data? {
    let encoder = JSONEncoder()
    return try? encoder.encode(value)
}

func formatCentsToDollars(_ cents: Int32) -> String {
    let dollars = abs(Double(cents)) / 100.0
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "USD"
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2

    let formattedAbsoluteValue = formatter.string(from: NSNumber(value: dollars)) ?? "$0.00"
    return cents < 0 ? "-\(formattedAbsoluteValue)" : formattedAbsoluteValue
}


struct ErrorMessage: Error {
    var message: String
}

extension ErrorMessage: CustomStringConvertible {
    var description: String {
        return self.message
    }
}

//let appIdKey = "app-uuid"
//func getAppId() async -> String {
//    let result : Result<String?, KeychainError> = await Keychain.get(key: appIdKey)
//        
//    if case .success(let appId) = result {
//        if let appId = appId {
//            return appId
//        }
//    }
//    
//    let newAppID = UUID().uuidString
//    
//    _ = await Keychain.upsert(key: appIdKey, item: newAppID)
//    
//    return newAppID
//}
