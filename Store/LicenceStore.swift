
//
//  UserInfoStore.swift
//  CleverVpnKit
//
//  Created by bolin wu on 2024/12/26.
//

import Foundation


class LicenceStore {
    static func load() async -> Result<Licence?, StoreError> {
        return await Keychain.get(key: StoreKeys.licence.prefixedValue)
            .mapError{ StoreError.keychain($0) }
    }

    static func save(licence: Licence) async -> Result<(), StoreError> {
        return await Keychain.upsert(key: StoreKeys.licence.prefixedValue, item: licence)
            .mapError { StoreError.keychain($0) }
    }
    
    static func delete() async -> Result<(), StoreError> {
        return await Keychain.delete(key: StoreKeys.licence.prefixedValue)
            .mapError { StoreError.keychain($0) }
    }
}
