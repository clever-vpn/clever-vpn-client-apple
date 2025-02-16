//
//  SignOutView.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/17.
//

import Foundation
import SwiftUI

struct SignOutView: View {
    @EnvironmentObject var vpnModel: CleverVpnModel

    @State private var isConfirming = false

    var body: some View {

        let key = vpnModel.userInfo?.key ?? "no key"
        Text(key)
        Button {
            isConfirming = true
        } label: {
            Text("DeActivate")
        }
        .confirmationDialog("Are you sure?", isPresented: $isConfirming) {
            Button {
                vpnModel.deActivate()
            } label: {
                Text("DeActivate")
            }

            Button("Cancel", role: .cancel) {
                isConfirming = false
            }
        }
    }
}


#Preview {
    SignOutView()
        .environmentObject(CleverVpnModel())
}
