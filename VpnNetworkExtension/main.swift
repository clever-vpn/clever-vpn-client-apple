// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import Foundation
import NetworkExtension
import CleverVpnKit

CleverVpnKitConfig.setSystemEx()
//CleverVpnPacketTunnelProvider.isSystemExtensionMode = true

autoreleasepool {
    NEProvider.startSystemExtensionMode()
    IPCCleverVpnKit.startService()
}

dispatchMain()

