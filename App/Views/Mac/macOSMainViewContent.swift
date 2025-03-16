//
//  MainViewContent.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/9.
//

import Foundation
import SwiftUI

#if os(macOS)
@available(macOS, introduced: 12, obsoleted: 13)
struct MainViewContent12: View {

    var body: some View {
        StackNavigationView {
            Text("Home").toolbar {
                StackNavigationLink(destination: SettingsView()) {
                    Label("Settings", systemImage: "gear")
                }.help("Settings")
            }
            
        }
    }
}

@available(macOS 13, *)
struct MainViewContent13: View {

    var body: some View {
        NavigationStack {
            VStack {
                HomeView()
            }.toolbar {
                NavigationLink(destination: SettingsView()) {
                    Label("Settings", systemImage: "gearshape")
                }.help("Settings")
            }
        }

    }
}

struct MainViewContent : View {
//    @State private var tabId = TabIdentifier.home
    
    var body: some View {
        VStack {
            if #available(macOS 13, *) {
                MainViewContent13()
            } else {
                MainViewContent12()
            }
        }.frame(minWidth: 400)
    }
}

/// A type that produces a view representing an icon.
//enum IconResource: Hashable {
//    /// A resource derived from a system symbol.
//    case systemSymbol(_ name: String)
//
//    /// A resource derived from an asset catalog.
//    case assetCatalog(_ resource: ImageResource)
//
//    /// The view produced by the resource.
//    @ViewBuilder
//    var view: some View {
//        image
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//    }
//
//    /// The image produced by the resource.
//    private var image: Image {
//        switch self {
//        case .systemSymbol(let name):
//            Image(systemName: name)
//        case .assetCatalog(let resource):
//            Image(resource)
//        }
//    }
//}

#Preview {
    MainViewContent().environmentObject(CleverVpnModel()).environmentObject(CleverVpnLogs())
}

#endif
