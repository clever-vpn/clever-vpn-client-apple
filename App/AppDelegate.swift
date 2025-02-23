//
//  AppDelegate.swift
//  Ice
//

import SwiftUI
import CleverVpnKit

#if os(macOS)
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Insert code here to initialize your application
        #if SYSTEMEX
            installSE()
        #endif
    }
}
#endif
