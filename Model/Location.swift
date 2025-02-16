//
//  Location.swift
//  CleverVpnKit
//
//  Created by bolin wu on 2024/12/23.
//

import Foundation

public struct Location : Codable, Hashable, Identifiable {
public    let id: Int
public    let code: String
public    let label: String
    public    let used: Int
    public init(id: Int, code: String, label: String, used: Int) {
        self.id = id
        self.code = code
        self.label = label
        self.used = used
    }
}
