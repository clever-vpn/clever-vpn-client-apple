//
//  AppIdStore.swift
//  CleverVpnKit
//
//  Created by bolin wu on 2025/1/5.
//

import Foundation

class AppIdStore {
    static func load() async  -> String {
        let result : Result<String?, KeychainError> = await Keychain.get(key: StoreKeys.appId.prefixedValue)
        
            if case .success(let appId) = result {
                if let appId = appId {
                    return appId
                }
            }
        
            let newAppID = UUID().uuidString
        
        _ = await Keychain.upsert(key: StoreKeys.appId.prefixedValue, item: newAppID)
        
            return newAppID
    }
}
