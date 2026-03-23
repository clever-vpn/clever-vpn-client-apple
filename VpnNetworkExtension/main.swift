// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import Foundation
import NetworkExtension
import CleverVpnKit

Variant.useSystemExtension = true

autoreleasepool {
    NEProvider.startSystemExtensionMode()
}

dispatchMain()

