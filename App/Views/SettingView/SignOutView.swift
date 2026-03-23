//
//  SignOutView.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/17.
//

import Foundation
import SwiftUI
import CleverVpnKit

struct SignOutView: View {
//    @EnvironmentObject var vpnModel: CleverVpnModel
    @EnvironmentObject var cleverVPNModel: VPNClient

    @State private var isConfirming = false

    var body: some View {
        
//        let key = vpnModel.userInfo?.key ?? "no key"
        let key0 = groupDigits(cleverVPNModel.userInfo?.key ?? "", len: 4)
        let key = key0.isEmpty ? "no key" : key0
        
        Text(key)
        Button {
            isConfirming = true
        } label: {
            Text("Logout")
        }
        .confirmationDialog("Are you sure?", isPresented: $isConfirming) {
            Button {
                cleverVPNModel.deActivate()
            } label: {
                Text("Logout")
            }

            Button("Cancel", role: .cancel) {
                isConfirming = false
            }
        }
    }
}


func groupDigits(_ s: String, len: Int) -> String {
    stride(from: 0, to: s.count, by: len).map {
        let start = s.index(s.startIndex, offsetBy: $0)
        let end = s.index(start, offsetBy: 4, limitedBy: s.endIndex) ?? s.endIndex
        return String(s[start..<end])
    }.joined(separator: "-")
}

#Preview {
    SignOutView()
        .environmentObject(vpnClient)
}
