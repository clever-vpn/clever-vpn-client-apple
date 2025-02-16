//
//  Licence.swift
//  CleverVpnKit
//
//  Created by bolin wu on 2024/12/27.
//

import Foundation
struct Licence : Codable, Hashable {
    let id: Int
    let locationId: Int?
    let licence: String
}
