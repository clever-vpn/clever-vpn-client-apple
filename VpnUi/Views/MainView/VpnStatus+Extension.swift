//
//  VpnStatus+Extension.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/11.
//

import Foundation
import CleverVpnKit

extension VpnStatus {
    func displayText() -> String {
        switch self {
        case .loading:
            "Loading"
        case .disconnected:
            "VPN is off"
        case .connecting:
            "Connecting"
        case .connected:
            "VPN is on"
        case .disconnecting:
            "Disconnecting"
        case .reconnecting:
            "Reconnecting"
        case .invalid:
            "Invalid"
        @unknown default:
            "Unknown"
        }
    }
    
    func shouldToggleBeOn() -> Bool {
        return switch self {
        case .disconnected, .disconnecting, .loading:
            false
        default:
            true
        }
    }
    
    func shieldSystemImage() -> String {
      return   if isConnected() {
          "checkmark.shield"
      }else {
          "shield.slash"
      }
//        return switch self {
//        case .connected:
//            "checkmark.shield"
//        default:
//            "shield.slash"
//        }
    }
    
    func isConnected() -> Bool {
        return switch self {
        case .connected, .reconnecting:
            true
        default:
            false
        }
    }

    func isDisconnected() -> Bool {
        if case .disconnected = self {
            return true
        }
        return false
    }
    
    func isDisconnectedOrConnected() -> Bool {
        return switch self {
        case .disconnected, .connected, .reconnecting:
            true
        default:
            false
        }
    }
}
    

