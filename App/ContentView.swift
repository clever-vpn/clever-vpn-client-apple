//
//  ContentView.swift
//  VpnUi
//
//  Created by bolin wu on 2024/12/31.
//

import CleverVpnKit
import SwiftUI

struct ContentView: View {
    //    @EnvironmentObject var vpnModel: CleverVpnModel
    @EnvironmentObject var cleverVPNModel: VPNClient
    @State private var isLastErrorPresented = false
    var body: some View {
        VStack {
            switch cleverVPNModel.activateStatus {
            case .waiting:
                WelcomeView()
            case .notActivate:
                AuthView()
            case .activate:
                MainView()
            }
        }
        .onReceive(cleverVPNModel.$lastError) { error in
            if let error = error, !error.description.isEmpty {
                isLastErrorPresented = true
            }
        }
        .alert(
            "Clever VPN Error",
            isPresented: $isLastErrorPresented,
            presenting: cleverVPNModel.lastError?.description
        ) { error in
            Button(role: .cancel) {
                cleverVPNModel.lastError = nil
            } label: {
                Text("OK")
            }
        } message: { error in
            Text(error)
        }

    }

}

#Preview {
    ContentView()
        .environmentObject(vpnClient)
        .environmentObject(logModel)
        .environmentObject(trafficModel)
}
