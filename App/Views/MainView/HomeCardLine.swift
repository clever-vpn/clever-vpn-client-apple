//
//  HomeCardLocation.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/12.
//

import Foundation
import SwiftUI
import CleverVpnKit

struct HomeCardLine: View {

//    @EnvironmentObject var vpnModel: CleverVpnModel
    @EnvironmentObject var cleverVPNModel: VPNClient

    @State private var showLineMenu = false


    var body: some View {
        HStack(spacing: 15) {

                if let line = cleverVPNModel.line {
                    LineIconView(iconKind: line.iconKind, icon: line.icon)
//                    FlagImage(countryCode: icon)
                        .padding(.trailing, 5)
                    Text(line.label)
                        .font(.headline)
                } else {
                Image(systemName: "globe").foregroundColor(.blue)
                Text("Auto Select Line")
                    .font(.headline)
            }
                



            if cleverVPNModel.status.isDisconnectedOrConnected() {
                if cleverVPNModel.status.isDisconnected()  {
                    Image(systemName: "pencil.circle")
                }else {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                    
                }
//                    .id(locationViewModel.locationsLastUpdated)
            } else {
                ProgressView()
                    .modifier(ScaleEffectModifier())
            }
        }
        .padding()
        .cornerRadius(15)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
//        .contextMenu {
//            ForEach(vpnModel.locations) {  location in
//                        Button {
//                            vpnModel.setLocation(selectedLocation: location)
//                        } label: {
//                            LocationView(location: location)
//                                .tag(location)
//                        }
//                        .disabled(!vpnModel.vpnStatus.isDisconnected())
//                    }
//        }
        .sheet(isPresented: $showLineMenu) {
            VStack {
                if #available(iOS 16, macOS 13, *) {
                    LineMenuView(close: $showLineMenu)
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.medium, .large])
                    
                } else {
                    LineMenuView(close: $showLineMenu)
                }
                
                
#if os(iOS)
                Divider()
                HStack {
                    Button {
                        cleverVPNModel.refreshLines()
                    } label : {
                        if cleverVPNModel.apiStatus == .connecting {
                            ProgressView()
                                .modifier(ScaleEffectModifier())
                        } else {
                            Text("Refresh")
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(cleverVPNModel.apiStatus == .connecting)
                }
#endif
            }
#if os(macOS)
            .frame(maxWidth: 300)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        showLineMenu.toggle()
                    } label : {
                        Text("Close")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        cleverVPNModel.refreshLines()
                    } label : {
                        if cleverVPNModel.apiStatus == .connecting {
                            if #available(macOS 13, *) {
                                ProgressView()
                                    .modifier(ScaleEffectModifier())
                            } else {
                                Text("Refresh")
                            }
                        } else {
                            Text("Refresh")
                        }
                    }
                    .disabled(cleverVPNModel.apiStatus == .connecting)
                }

            }
#endif
        }
        .onTapGesture {
//            if vpnModel.locations.count > 0 {
                showLineMenu.toggle()
//            }
        }
    }
    
}

struct ToolBarModifier : ViewModifier {
    func body(content: Content) -> some View {
        content.toolbar {
            
        }
        if #available(macOS 14, *) {
            content
            #if os(macOS)
                .scaleEffect(0.55)
            #endif
        } else {
            content
        }
    }
}


#Preview {
    HomeCardLine()
        .environmentObject(vpnClient)
}
