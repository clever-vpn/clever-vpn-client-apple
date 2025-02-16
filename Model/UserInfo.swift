//
//  UserInfo.swift
//  CleverVpnKit
//
//  Created by bolin wu on 2024/12/26.
//

import Foundation

public enum ProtocolType : String, Codable, CaseIterable, Identifiable {
    case auto = "AUTO"
    case udp = "UDP"
    case kudp = "KUDP"
    case tcp = "TCP"
    public var id: String { self.rawValue }
}

public struct UserInfo : Codable, Hashable {
public    let key: String?
public    let locationId: Int?
    public let url: String?
public    let protocolType: ProtocolType
    public init(key: String?, locationId: Int?, url: String? = nil, protocolType: ProtocolType = .auto) {
        self.key = key
        self.locationId = locationId
        self.protocolType = protocolType
        self.url = url
    }
}

