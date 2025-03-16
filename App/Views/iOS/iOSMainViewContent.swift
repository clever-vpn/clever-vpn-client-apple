//
//  MainViewContent.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/9.
//

import Foundation
import SwiftUI

#if os(iOS)
struct MainViewContent : View {
    @EnvironmentObject var vpnModel: CleverVpnModel
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack {
                    HomeView()
                }.toolbar {
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gearshape")
                    }.help("Settings")
                }
            }
        }else {
            NavigationView {
                VStack {
                    HomeView()
                }.toolbar {
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gearshape")
                    }.help("Settings")
                }
                
            }.navigationViewStyle(StackNavigationViewStyle())

        }
    }
}
#endif
