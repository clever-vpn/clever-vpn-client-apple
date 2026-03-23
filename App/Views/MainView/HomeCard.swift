//
//  HomeCard.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/9.
//

import SwiftUI
import CleverVpnKit

struct HomeCard: View {
//    @EnvironmentObject var vpnModel: CleverVpnModel
    @EnvironmentObject var cleverVPNModel: VPNClient

    private var isOnBinding: Binding<Bool> {
            Binding(
                get: { cleverVPNModel.status.shouldToggleBeOn() },
                set: { newValue in
                    if newValue != cleverVPNModel.status.shouldToggleBeOn() {
                        if newValue {
                            cleverVPNModel.startVPN()
                        } else {
                            cleverVPNModel.stopVPN()
                        }
                    }
                }
            )
        }


    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 15) {

                Image(systemName: cleverVPNModel.status.shieldSystemImage())
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(cleverVPNModel.status.isConnected() ? Color.green : Color.black)
                    .frame(minWidth: 50, maxWidth: 100,  minHeight: 50, maxHeight: 100)
                    .font(.headline.weight(.light))

//                if !vpnModel.vpnStatus.isConnected() {
//                    Text(vpnModel.vpnStatus.displayText())
//                        .font(.headline)
//                        .padding(.bottom, 2).padding(.top, 2)
//                        .padding(.trailing, 10)
//                        .padding(.leading, 10)
//                        .background(
//                            Capsule().stroke()
//                        )
//                }
            }

            HomeCardDivider()
                .padding(.vertical).frame(height: 80)

            VStack(spacing: 15) {
                HomeCardLine()

                Toggle("", isOn: isOnBinding)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .disabled(!cleverVPNModel.status.isDisconnectedOrConnected())
            }
            Spacer()
        }
        .padding(.vertical, 10)
        .background(Color.uSecondarySystemGroupedBackground)
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeCard()
        .environmentObject(vpnClient)
}

//#Preview {
//    HomeCard(tunnelStatus: TunnelStatus.connected(Location.default, Date.now))
//        .environmentObject(LocationViewModel(dataRepository: DataRepository.shared, isDisconnected: { return true }))
//}
//
//#Preview {
//    HomeCard(tunnelStatus: TunnelStatus.serverRunning(Location.default))
//        .environmentObject(LocationViewModel(dataRepository: DataRepository.shared, isDisconnected: { return true }))
//}

