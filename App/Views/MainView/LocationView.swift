//
//  LocationView.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/9.
//


import SwiftUI
import FlagKit
import CleverVpnKit

struct LocationView: View {
    var location: Location?

    @EnvironmentObject var vpnModel: CleverVpnModel

    var body: some View {
        HStack(spacing: 15) {
            if let location = location {
                FlagImage(countryCode: location.code)
                Text(location.label)
                    .font(.headline)
            }else {
                Image(systemName: "globe").foregroundColor(.blue)
                Text("Auto Select Adress")
                    .font(.headline)
            }
            Spacer()
            if (location?.id == vpnModel.location?.id) {
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
            vpnModel.setLocation(selectedLocation: location)
        }
    }
}

#Preview {
    LocationView(location: Location(id:1, code: "US", label: "LAX", used: 0))
        .environmentObject(CleverVpnModel())
}
