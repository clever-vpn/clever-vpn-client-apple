//
//  HomeView.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/9.
//

import Foundation
import SwiftUI
import CleverVpnKit

struct HomeView: View {
//    @EnvironmentObject var vpnModel: CleverVpnModel
    @EnvironmentObject var cleverVPNModel: VPNClient
    @EnvironmentObject var cleverVPNTrafficModel: VPNTrafficModel

    var body: some View {
        GeometryReader { reader in
            VStack(spacing: 0) {
                ZStack {

                    Rectangle()
                        .fill(Color.uSystemGroupedBackground)
                        .ignoresSafeArea()

                    HomeCard()
                    #if os(iOS)
                    .padding(.horizontal)
                    // to match padding as much as the card below it
                    .padding(.horizontal, 3)
                    // to keep distance from status bar at top
                    .padding(.top, 5)
                    #endif
                    #if os(macOS)
                    .padding([.leading, .top, .trailing])
                    #endif
                }.frame( minHeight: reader.size.height * 0.55)
                
                if cleverVPNModel.status.isConnected() {
                    CardContainer {
                        StatsCard(
                            tx: prettyBytes(UInt64(cleverVPNTrafficModel.traffic?.uplinkTotal ?? 0)),
                            rx: prettyBytes(UInt64(cleverVPNTrafficModel.traffic?.downlinkTotal ?? 0))
                        )
                        
//                        StatsCard(tx:"\(vpnModel.runtimeConfiguration.tx)", rx: "\(vpnModel.runtimeConfiguration.rx)")


                    }
                    .contentShape(Rectangle())
//                    .onTapGesture {
//                        onStatsTap()
//                    }
                    //                    CardContainer {
                    //                        if let runtimeConfig = tunnelViewModel.tunnelObserver.runtimeConfig {
                    //                            if let peer = runtimeConfig.peers.first {
                    //                                if let tx = peer.txBytes, let rx  = peer.rxBytes {
                    //                                    StatsCard(tx: prettyBytes(tx), rx: prettyBytes(rx))
                    //                                }
                    //                            }
                    //                        }
                    //                    }
                } else {
//                    if locationViewModel.recentLocations.isEmpty {
                        if true {
                        CardContainer {
                            WelcomeView(showSpinnner: false)
                        }
                    } else {
//                        RecentLocationsCard()
//                        #if os(macOS)
//                            .cornerRadius(10)
//                            .padding()
//                        #endif
                    }
                }
            }
        }
        .onAppear {
            cleverVPNTrafficModel.setViewGateOpen(true)
        }
        .onDisappear {
            cleverVPNTrafficModel.setViewGateOpen(false)
        }

    }
}

func prettyBytes(_ bytes: UInt64) -> String {
    switch bytes {
    case 0..<1024:
        return "\(bytes) B"
    case 1024 ..< (1024 * 1024):
        return String(format: "%.2f", Double(bytes) / 1024) + " KiB"
    case 1024 ..< (1024 * 1024 * 1024):
        return String(format: "%.2f", Double(bytes) / (1024 * 1024)) + " MiB"
    case 1024 ..< (1024 * 1024 * 1024 * 1024):
        return String(format: "%.2f", Double(bytes) / (1024 * 1024 * 1024)) + " GiB"
    default:
        return String(format: "%.2f", Double(bytes) / (1024 * 1024 * 1024 * 1024)) + " TiB"
    }
}


#Preview {
    HomeView()
        .environmentObject(vpnClient)
        .environmentObject(trafficModel)
}

