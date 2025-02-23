//
//  VpnUiApp.swift
//  VpnUi
//
//  Created by bolin wu on 2024/12/31.
//

import SwiftUI
import CleverVpnKit

@main
struct VpnUiApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor var appDelegate: AppDelegate
    #endif

    @StateObject private var vpnModel = CleverVpnModel()
    @StateObject private var logModel = CleverVpnLogs()
    @State private var currentImageIndex = 0
    private let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
    private let images = ["StatusBarIconDot1", "StatusBarIconDot2", "StatusBarIconDot3"]
    var body: some Scene {
        windowScene()

        #if os(macOS)
        if #available(macOS 13, *) {
            MenuBarExtra {
                MenuBarExtraView()
                    .onAppear {
                        // to load new locations and/or estimates
//                        locationViewModel.reload()
                    }
                    .environmentObject(vpnModel)
                    .environmentObject(logModel)
            } label: {
                switch vpnModel.vpnStatus {
                case .connecting:
                    Image(images[currentImageIndex])
                        .onReceive(timer) { _ in
                            currentImageIndex = (currentImageIndex + 1) % images.count
                        }
                case .connected:
                    Image("StatusBarIcon")
                                           .renderingMode(.original)
                default:
                    Image("StatusBarIconDimmed")
                                          .renderingMode(.template)
                }
            }
            .menuBarExtraStyle(.window)
//            .menuBarExtraAccess(isPresented: $isPresented)
        }
        #endif
    }
    
    private func getContentView() -> some View {
        return ContentView()
            .environmentObject(vpnModel).environmentObject(logModel)
            #if os(macOS)
            .frame(minHeight: 650)
            #endif
    }

    
    func windowScene() -> some Scene {
        #if os(macOS)
        if #available(macOS 13, *) {
            return Window("Clever VPN", id: "main") {
                getContentView()
            }
            .windowResizability(.contentSize)

        } else {
            return WindowGroup {
                getContentView()
            }
        }
        #else
        return WindowGroup {
            getContentView()
        }
        #endif
    }
}

