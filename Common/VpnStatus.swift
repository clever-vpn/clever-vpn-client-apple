//
//  VPNState.swift
//  CleverVpnKit
//
//  Created by bolin wu on 2024/12/23.
//

import Foundation

public enum VpnStatus : Codable {
    case invalid
    case disconnected
    case connecting
    case connected
    case reconnecting
    case disconnecting
    case loading
    
}

//extension VPNState {
//    func toDisconnecting() -> Self {
//        return switch self {
//        case .disconnected:
//            self
//        case .requesting(let location),
//                .accepted(let location),
//                .serverCreated(let location),
//                .serverRunning(let location),
//                .serverReady(let location),
//                .connecting(let location),
//                .connected(let location, _),
//                .disconnecting(let location):
//                .disconnecting(location)
//        }
//    }
//}
