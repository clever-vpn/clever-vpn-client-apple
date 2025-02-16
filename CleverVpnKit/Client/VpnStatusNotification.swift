//
//  VpnStatusNotification.swift
//  CleverVpnKit
//
//  Created by bolin wu on 2025/1/11.
//

import Foundation
import NetworkExtension

public class VpnStatusNotification: AsyncSequence {
    public typealias Element = VpnStatus
    public func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator()
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        private var innerIterator = NotificationCenter.default.notifications(named: .NEVPNStatusDidChange)
            .makeAsyncIterator()

        public mutating func next() async  -> VpnStatus? {

            return await innerIterator.next().map { notification in
                guard let session = notification.object as? NETunnelProviderSession else {
                    return .invalid
                }
                return neVPNStatusToVpnStatus(session.status)
            }

        }
    }
}


func neVPNStatusToVpnStatus(_ status: NEVPNStatus) -> VpnStatus {
    return switch status {
    case .connected: .connected
    case .connecting: .connecting
    case .disconnected: .disconnected
    case .disconnecting: .disconnecting
    case .invalid: .invalid
    case .reasserting: .reconnecting
    @unknown default: .invalid
    }
}
