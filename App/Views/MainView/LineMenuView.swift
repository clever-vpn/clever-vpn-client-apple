//
//  LineMenuView.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/14.
//

import Foundation
import SwiftUI
import CleverVpnKit

struct LineMenuView: View {
    //    @EnvironmentObject var vpnModel: CleverVpnModel
    @EnvironmentObject var cleverVPNModel: VPNClient
    
    @Binding var close: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                LineBadgeLegendView()

                ForEach(cleverVPNModel.lines) {  line in
                    lineItem(line: line)
                }
                if cleverVPNModel.lines.isEmpty {
                    lineItem(line: nil)
                }

            }
        }
        .padding(.horizontal, 20)
        
    }
    
    @ViewBuilder
    private func lineItem(line: Line?) -> some View {
        Button {
            cleverVPNModel.updateLine(id: line?.id)
#if os(macOS)
            close.toggle()
#endif
        } label: {
            LineView(line: line)
        }
        .disabled(!(cleverVPNModel.status.isDisconnected()))
    }
}

private struct LineBadgeLegendView: View {
    var body: some View {
        HStack(spacing: 10) {
            Text("xN = Factor")
                .font(.caption)
                .foregroundColor(.secondary)
            LineLegendItem(systemImage: "dot.radiowaves.left.and.right", text: "Relay", tint: .mint)
            LineLegendItem(systemImage: "arrow.up.forward.circle.fill", text: "Upstream Proxy", tint: .blue)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 4)
    }
}

private struct LineLegendItem: View {
    let systemImage: String
    let text: LocalizedStringKey
    let tint: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.caption2.weight(.semibold))
                .foregroundColor(tint)

            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
