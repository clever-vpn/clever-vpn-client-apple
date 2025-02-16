//
//  MainView.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/9.
//

import Foundation

import SwiftUI

struct MainView: View {
    @EnvironmentObject var vpnModel: CleverVpnModel
    var body: some View {
        MainViewContent()
        .navigationTitle("Clever VPN")
    }
}

#Preview {
    MainView().environmentObject(CleverVpnModel())
}
