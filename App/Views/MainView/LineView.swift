//
//  LineView.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/9.
//


import Foundation
import SwiftUI
import CleverVpnKit

struct LineView: View {
    var line: Line?
    @EnvironmentObject var cleverVPNModel: VPNClient
    
    private var isSelected: Bool {
        line?.id == cleverVPNModel.line?.id
    }
    
    //    @EnvironmentObject var vpnModel: CleverVpnModel
    
    var body: some View {
        HStack(spacing: 10) {
            if let line = line {
                LineIconView(iconKind: line.iconKind, icon: line.icon)

                HStack(spacing: 4) {
                    Text(line.label)
                        .font(.headline)
                        .lineLimit(1)

                    Text(factorText(line.factor))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: true, vertical: false)
                }
                    .layoutPriority(1)

                HStack(spacing: 4) {
                    if line.hasRelay {
                        LineFeatureIcon(
                            systemImage: "dot.radiowaves.left.and.right",
                            tint: .mint,
                            accessibilityText: "Relay"
                        )
                    }
                    if line.hasUpstream {
                        LineFeatureIcon(
                            systemImage: "arrow.up.forward.circle.fill",
                            tint: .blue,
                            accessibilityText: "Upstream Proxy"
                        )
                    }
                }
                .lineLimit(1)
            } else {
                Image(systemName: "globe")
                    .foregroundColor(.blue)
                Text("Auto Select Line")
                    .font(.headline)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(isSelected ? Color.green.opacity(0.12) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color.green.opacity(0.3) : Color.secondary.opacity(0.12), lineWidth: 1)
        )
        .cornerRadius(15)
        .contentShape(Rectangle())
    }

    private func factorText(_ factor: Double) -> String {
        if factor.rounded() == factor {
            return "x\(String(format: "%.0f", factor))"
        }
        return "x\(String(format: "%.2f", factor))"
    }
}

private struct LineFeatureIcon: View {
    let systemImage: String
    let tint: Color
    let accessibilityText: LocalizedStringKey

    var body: some View {
        Image(systemName: systemImage)
            .font(.caption2.weight(.semibold))
            .foregroundColor(tint)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(accessibilityText))
    }
}

#Preview {
    LineView(line: Line(id:1, label: "United States", factor: 1.25, icon: "US", iconKind: nil, isDefault: false, hasRelay: true, hasUpstream: true))
        .environmentObject(vpnClient)
}
