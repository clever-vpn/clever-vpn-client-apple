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
                        Text(option.rawValue)

                        Text(option.description)
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
                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
                let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""

                Text("(\(appVersion)-\(appBuild))")
            }
        }
        .modifier(FormModifier())
        .navigationTitle("Settings")
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
