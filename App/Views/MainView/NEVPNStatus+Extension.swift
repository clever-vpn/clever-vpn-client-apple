//
//  VpnStatus+Extension.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/11.
//

import Foundation
import NetworkExtension
import CleverVpnKit

extension NEVPNStatus {
    func displayText() -> String {
        switch self {
        case .disconnected:
            NSLocalizedString("VPN is off", comment: "")
        case .connecting:
            NSLocalizedString("Connecting", comment: "")
        case .connected:
            NSLocalizedString("VPN is on", comment: "")
        case .disconnecting:
            NSLocalizedString("Disconnecting", comment: "")
        case .invalid:
            NSLocalizedString("Invalid", comment: "")
        case .reasserting:
            NSLocalizedString("Reasserting", comment: "")
        @unknown default:
            NSLocalizedString("Unknown", comment: "")
        }
    }
    
    func shouldToggleBeOn() -> Bool {
        return switch self {
        case .disconnected, .disconnecting, .invalid:
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
    }
    
    func isConnected() -> Bool {
        return switch self {
        case .connected:
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
        case .disconnected, .connected:
            true
        default:
            false
        }
    }
}
    

