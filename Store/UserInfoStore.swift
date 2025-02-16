//
//  UserInfoStore.swift
//  CleverVpnKit
//
//  Created by bolin wu on 2024/12/26.
//

import Foundation



class UserInfoStore {
    
    static func load() async -> Result<UserInfo?, StoreError> {
        return await Keychain.get(key: StoreKeys.userInfo.prefixedValue)
            .mapError{ StoreError.keychain($0) }
    }

    static func save(userInfo: UserInfo) async -> Result<(), StoreError> {
        return await Keychain.upsert(key: StoreKeys.userInfo.prefixedValue, item: userInfo)
            .mapError { StoreError.keychain($0) }
    }
    
    static func delete() async -> Result<(), StoreError> {
        return await Keychain.delete(key: StoreKeys.userInfo.prefixedValue)
            .mapError { StoreError.keychain($0) }
    }
    
}


