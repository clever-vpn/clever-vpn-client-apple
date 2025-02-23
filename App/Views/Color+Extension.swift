//
//  Color+Extension.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/8.
//

import Foundation
import SwiftUI

extension Color {
    static var uSystemGroupedBackground: Color {
        #if os(iOS)
        return Color(uiColor: .systemGroupedBackground)
        #elseif os(tvOS)
        return Color(uiColor: .clear)
        #elseif os(macOS)
        return Color.clear
        #endif
    }

    static var uSecondarySystemGroupedBackground: Color {
        #if os(iOS)
        return Color(uiColor: .secondarySystemGroupedBackground)
        #elseif os(tvOS)
        return Color(uiColor: .clear)
        #elseif os(macOS)
        return Color(nsColor: .controlBackgroundColor)
        #endif
    }
}
