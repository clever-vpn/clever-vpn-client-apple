//
//  StoreKey.swift
//  CleverVpnKit
//
//  Created by bolin wu on 2025/1/5.
//

import Foundation

enum StoreKeys : String {
    case appId = "app-uuid"
    case userInfo = "user-Info"
    case licence = "licence"
    
    static var keyPrefix = "clever-vpn-kit-"
        
    var prefixedValue: String {
        return "\(StoreKeys.keyPrefix)\(self.rawValue)"
    }
    
}
