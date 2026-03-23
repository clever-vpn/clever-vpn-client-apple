//
//  LocationView.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/9.
//


import SwiftUI
import FlagKit
import CleverVpnKit

struct LineView: View {
    var line: Line?
    @EnvironmentObject var cleverVPNModel: VpnClient
    
    //    @EnvironmentObject var vpnModel: CleverVpnModel
    
    var body: some View {
        HStack(spacing: 15) {
            if let line = line {
                if line.iconKind != "service" , let icon = line.icon{
                    FlagImage(countryCode: icon)
                    Text(line.label)
                        .font(.headline)
                }else {
                    Image(systemName: "globe").foregroundColor(.blue)
                }
            }else {
                Image(systemName: "globe").foregroundColor(.blue)
                Text("Auto Select Adress")
                    .font(.headline)
            }
            Spacer()
            if (line?.id == cleverVPNModel.line?.id) {
                Image(systemName: "checkmark.circle").foregroundColor(Color.green)
            }
        }
        .padding()
        .cornerRadius(15)
        // contentShape and onTapGuesture is only required for iOS 15
        // Because List selection doesn't work, follwing note from the link:
        // https://developer.apple.com/documentation/swiftui/list
        // In iOS 15, iPadOS 15, and tvOS 15 and earlier, lists support selection
        // only in edit mode, even for single selections.
        .contentShape(Rectangle())
        // contentShape for: https://stackoverflow.com/questions/57191013/swiftui-cant-tap-in-spacer-of-hstack
        .onTapGesture {
            cleverVPNModel.updateLine(id: line?.id)   }
    }
}

#Preview {
    LineView(line: Line(id:1, label: "United States", icon: "US"))
        .environmentObject(CleverVpnModel())
}
