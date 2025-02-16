//
//  HomeCardDivider.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/9.

import SwiftUI

struct HomeCardDivider: View {
    @EnvironmentObject var vpnModel: CleverVpnModel


    var body: some View {

        switch vpnModel.vpnStatus {

        case  .connecting:
            ProgressView(value: 0.5)
                .padding(.horizontal, 30)
        case .connected, .reconnecting:
            HStack {
                // embeded in vstack because divider in hstack becomes vertical
                VStack {
                    Divider()
                        .padding(.leading, 30)
                        .padding(.trailing, 10)
                }
                ElapsedTimeView(startDate: vpnModel.startTime ?? Date.now)
                    .frame(minWidth: 100, maxWidth: 110)
                VStack {
                    Divider()
                        .padding(.leading, 10)
                        .padding(.trailing, 30)
                }
            }
            
        default:
            Divider()
                .padding(.horizontal, 30)

        }
    }
}

#Preview {
    HomeCardDivider().environmentObject(CleverVpnModel())
}
