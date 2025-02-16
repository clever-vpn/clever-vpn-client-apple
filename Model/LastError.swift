//
//  LastError.swift
//  CleverVpnKit
//
//  Created by bolin wu on 2025/1/16.
//

import Foundation

struct LastError: Codable {
    let startRequestId: String
    let error: CleverVpnError
}
