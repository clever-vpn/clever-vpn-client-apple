//
//  LocationMenuView.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/14.
//

import Foundation
import SwiftUI
import CleverVpnKit

struct LocationMenuView: View {
    @EnvironmentObject var vpnModel: CleverVpnModel
    @Binding var close: Bool

    var body: some View {
        ScrollView {
            VStack {
                locationItem(location: nil)

                ForEach(vpnModel.locations) {  location in
//                    Button {
//                        vpnModel.setLocation(selectedLocation: location)
//#if os(macOS)
//                        close.toggle()
//#endif
//                    } label: {
//                        LocationView(location: location)
//                            .tag(location)
//                    }
//                    .disabled(!vpnModel.vpnStatus.isDisconnected())
                    locationItem(location: location)
                }
            }
        }
        .padding(.horizontal, 20)
        
    }
    
    @ViewBuilder
    private func locationItem(location: Location?) -> some View {
        Button {
            vpnModel.setLocation(selectedLocation: location)
#if os(macOS)
            close.toggle()
#endif
        } label: {
            LocationView(location: location)
                .tag(location)
        }
        .disabled(!vpnModel.vpnStatus.isDisconnected())

    }
    
}
