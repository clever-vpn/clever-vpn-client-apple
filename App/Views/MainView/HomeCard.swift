//
//  HomeCard.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/9.
//

import SwiftUI

struct HomeCard: View {
    @EnvironmentObject var vpnModel: CleverVpnModel

    private var isOnBinding: Binding<Bool> {
            Binding(
                get: { vpnModel.vpnStatus.shouldToggleBeOn() },
                set: { newValue in
                    if newValue != vpnModel.vpnStatus.shouldToggleBeOn() {
                        if newValue {
                            vpnModel.turnOn(true)
                        } else {
                            vpnModel.turnOn(false)
                        }
                    }
                }
            )
        }


    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 15) {

                Image(systemName: vpnModel.vpnStatus.shieldSystemImage())
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(vpnModel.vpnStatus.isConnected() ? Color.green : Color.black)
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
                HomeCardLocation()

                Toggle("", isOn: isOnBinding)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .disabled(!vpnModel.vpnStatus.isDisconnectedOrConnected())
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
        .environmentObject(CleverVpnModel())
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

