//
//  SettingsView.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/9.
//

import CleverVpnKit
import Foundation
import SwiftUI

struct SettingsView: View {
    //    @EnvironmentObject var vpnModel: CleverVpnModel
    @EnvironmentObject var cleverVPNModel: VPNClient
    @State var selectedProtocol: ProtocolType = .auto

    var body: some View {
        Form {
            Section("User ID") {
                SignOutView()
            }

            Section("Protocol Type") {
                ForEach(ProtocolType.allCases) { option in
                    HStack {
                        Text(option.localizedTitle)

                        Text(option.localizedDescription)
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        Spacer()

                        if option == self.selectedProtocol {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.selectedProtocol = option
                        cleverVPNModel.updateProtocolType(protocolType: option)
                    }
                }
            }.onAppear {
                if let protocolType = cleverVPNModel.userInfo?.protocolType {
                    Task { @MainActor in
                        self.selectedProtocol = protocolType
                    }
                }
            }
 
            Section("Split Routing") {
                NavigationLinkEx(destination: SplitSettingsView()) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Split Routing")
                        Text("Configure region, domain, and IP rules")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                }
            }

           Section("Connection Info") {
                connectionInfoRow(title: "Protocol", value: displayConnValue(cleverVPNModel.connInfo?.protocolType))
                connectionInfoRow(title: "Relay", value: displayConnValue(cleverVPNModel.connInfo?.relayIP))
                connectionInfoRow(title: "Upstream", value: displayConnValue(cleverVPNModel.connInfo?.upStream))
            }

            #if os(macOS)
                if #available(macOS 13, *) {
                    Section("Launch at Login") {
                        LaunchAtLogin.Toggle()
                    }
                }
            #endif

                        Section("Log View") {
                            NavigationLinkEx(destination: LogView()) {
                                Text("Log View")
                            }
                        }

                        Section("About us") {
                            let urlString = cleverVPNModel.userInfo?.providerUrl ?? "https://github.com/clever-vpn/clever-vpn-client-apple"
                            if let url = URL(string: urlString) {
                                Link("Clever VPN", destination: url)
                            }
                        }

            Section("Version") {
                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? NSLocalizedString("Unknown", comment: "")
                let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""

                Text("(\(appVersion)-\(appBuild))")
            }
        }
        .modifier(FormModifier())
        .navigationTitle("Settings")
    }

}

private extension SettingsView {
    @ViewBuilder
    func connectionInfoRow(title: LocalizedStringKey, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
                .textSelection(.enabled)
        }
    }

    func displayConnValue(_ value: String?) -> String {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
            return NSLocalizedString("None", comment: "")
        }
        return trimmed
    }
}

struct FormModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16, macOS 13.0, *) {
            content.formStyle(.grouped)
        } else {
            content
        }
    }
}

#Preview {
    SettingsView().environmentObject(vpnClient)
}

private extension ProtocolType {
    var localizedTitle: String {
        switch self {
        case .auto:
            return NSLocalizedString("Auto", comment: "")
        case .udpTunnel:
            return NSLocalizedString("UDP Tunnel", comment: "")
        case .udpFast:
            return NSLocalizedString("UDP Fast", comment: "")
        case .udpStable:
            return NSLocalizedString("UDP Stable", comment: "")
        case .tcpFast:
            return NSLocalizedString("TCP Fast", comment: "")
        case .tcpStable:
            return NSLocalizedString("TCP Stable", comment: "")
        @unknown default:
            return NSLocalizedString("Unknown", comment: "")
        }
    }

    var localizedDescription: String {
        switch self {
        case .auto:
            return NSLocalizedString("Automatic protocol selection (default)", comment: "")
        case .udpTunnel:
            return NSLocalizedString("Use UDP for the L3 tunnel", comment: "")
        case .udpFast:
            return NSLocalizedString("Use fast UDP", comment: "")
        case .udpStable:
            return NSLocalizedString("Use stable UDP", comment: "")
        case .tcpFast:
            return NSLocalizedString("Use fast TCP", comment: "")
        case .tcpStable:
            return NSLocalizedString("Use stable TCP", comment: "")
        @unknown default:
            return NSLocalizedString("Unknown", comment: "")
        }
    }
}
