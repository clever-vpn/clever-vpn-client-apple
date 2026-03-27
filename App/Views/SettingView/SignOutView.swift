//
//  SignOutView.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/17.
//

import Foundation
import SwiftUI
import CleverVpnKit

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct SignOutView: View {
//    @EnvironmentObject var vpnModel: CleverVpnModel
    @EnvironmentObject var cleverVPNModel: VPNClient

    @State private var isConfirming = false
    @State private var didCopyUserID = false

    var body: some View {
        let rawKey = cleverVPNModel.userInfo?.key ?? ""
        let groupedKey = groupDigits(rawKey, len: 4)
        let displayedKey = groupedKey.isEmpty ? NSLocalizedString("No key", comment: "") : groupedKey

        HStack(alignment: .firstTextBaseline, spacing: 8) {
            selectableUserIDText(displayedKey)
                .font(.body.monospaced())
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                copyUserID(displayedKey)
            } label: {
                Image(systemName: didCopyUserID ? "checkmark" : "doc.on.doc")
                    .foregroundColor(didCopyUserID ? .green : .accentColor)
            }
            .buttonStyle(.plain)
            .disabled(groupedKey.isEmpty)
            .help(didCopyUserID ? "Copied" : "Copy User ID")
            .accessibilityLabel(Text(didCopyUserID ? "Copied" : "Copy User ID"))
        }

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

    @ViewBuilder
    private func selectableUserIDText(_ text: String) -> some View {
        if #available(iOS 15, macOS 12, *) {
            Text(verbatim: text)
                .textSelection(.enabled)
        } else {
            Text(verbatim: text)
        }
    }

    private func copyUserID(_ text: String) {
        #if os(iOS)
        UIPasteboard.general.string = text
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif

        didCopyUserID = true

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            didCopyUserID = false
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
