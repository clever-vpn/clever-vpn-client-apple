//
//  SettingsView.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/9.
//

import Foundation
import SwiftUI
import CleverVpnKit

extension ProtocolType {
    public var description: String {
        switch self {
        case .udp:
            return "for low packet loss"
        case .kudp:
            return "for high packet loss"
        case .tcp:
            return "UDP not available"
        case .auto:
            return "auto Select Protocol (default)"
        @unknown default:
            return "Unknown"
            
        }
    }
}



struct SettingsView: View {
    @EnvironmentObject var vpnModel: CleverVpnModel
    @State private var selectedProtocol: ProtocolType = .auto
    
    var body: some View {
        Form {
            Section("Activative Key") {

                SignOutView()
//                AccountView()
//
//                NavigationLink("Plan") {
//                    PlanManagement(isRefreshable: true)
//                }
//
//                NavigationLink("Help") {
//                    HelpView()
//                }

            }
            Section("Protocol Type") {
                List(ProtocolType.allCases) { option in
                    HStack {
                        Text(option.rawValue)
                        
                        Text(option.description)
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        Spacer()

                        if option == selectedProtocol {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedProtocol = option
                        vpnModel.setProtocolType(protocolType: option)
                    }
                }.onAppear {
                    selectedProtocol = vpnModel.userInfo?.protocolType ?? .auto
                }
                
            }
            
            #if os(macOS)
            if #available(macOS 13, *)
            {
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
            
            if let url = vpnModel.userInfo?.url {
                    Section("About us") {
                        Link("Clever VPN", destination: URL(string: url)!)
                    }
            }
                
            Section("Version") {
                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
                let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
                //                    appVersion += " (\(appBuild))"
//                }
                

                    Text("(\(appVersion + appBuild))")
                           }

//            SignOutView()
        }
        .modifier(FormModifier())
        .navigationTitle("Settings")
    }
    
//    var body: some View {
//        VStack {
//            
//            Button(action: {
//                vpnModel.deActivate()
//            }) {
//                Text("DeActivate")
//            }
//
////            Button(action: {
////                vpnModel.turnOn(true)
////            }) {
////                Text("Turn On")
////            }
//            
//            NavigationLinkEx(destination: AuthView()) {
//                Text("Activate")
//            }
//            
//            if #available(macOS 14, *) {
//                
//                Button("Hello, world!") {
//                    isShowingInspector.toggle()
//                }
//                .font(.largeTitle)
//                .sheet(isPresented: $isShowingInspector) {
//                    Text("Inspector View")
//                }
//            }
////            if #available(macOS 13, *) {
////                NavigationLink(destination: LogView()) {
////                    Text("Log Detail")
////                }
////            }else
////            {
////                StackNavigationLink(destination: LogView()) {
////                    Text("Log Detail-12")
////                }
////            }
//            
//            NavigationLinkEx(destination: LogView()) {
//                Text("Log Detail")
//            }
//            
//        }
//    }
    
    
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
    SettingsView().environmentObject(CleverVpnModel())
}
