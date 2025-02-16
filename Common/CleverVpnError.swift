//
//  LicenceError.swift
//  CleverVpnKit
//
//  Created by bolin wu on 2024/12/27.
//

import Foundation

public enum CleverVpnError: Error, Codable {
    case vpnProviderFrozen
    case customerFrozen
    case noServer
    case noCustomer
    case noVpnProvider
    case noKey
    case apiError(ApiError)
    case tunnelError(String)
    case invalid
}

extension CleverVpnError: CustomStringConvertible {
    public var description: String {
        return switch self {
        case .vpnProviderFrozen:
            "vpn provider account is frozen!"
        case .customerFrozen:
            "the key is frozen!"
        case .noServer:
            "no server"
        case .noCustomer:
            "cannot find valid activate key"
        case .noVpnProvider:
            "no vpn provider"
        case .noKey:
            "no activiate key"
        case .invalid:
            "licence invalid"
        case .apiError(let error):
            error.description
        case .tunnelError(let error):
            error.description
        }
    }
}



//VPNProviderFrozen = 1,
//CustomerFrozen,
//NoServer, // provider没有创建服务器，等待provider提供服务器，app等一段时间再查询。
//NoCustomer,  // 激活码找不到，就是NoCustomer
//NoVPNProvider, //provider找不到，它是用在未来的自定义app中。
