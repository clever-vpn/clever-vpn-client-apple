//
//  UserDataConsent.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/8.
//

import Foundation

import SwiftUI

struct UserDataConsent: View {
    var body: some View {
        CardContainer {
            Text("""
For the app to work with the Clever VPN service and in-app purchases, the following device data is associated with your account:

- Unique random device ID
- Device name or hostname
- OS version and type
- CPU architecture
- User ID

**Clever VPN values your privacy**. You can sign out from the device and delete your data by deactivating at any time.
""")
            .padding()
            .frame(minWidth: 300,  maxWidth: 500, minHeight: 300, maxHeight: .infinity)
            .multilineTextAlignment(.leading)

        }
    }
}

#Preview {
    UserDataConsent()
}
