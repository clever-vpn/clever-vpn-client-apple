//
//  HomeCardLocation.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/12.
//

import Foundation

import SwiftUI

struct HomeCardLocation: View {

    @EnvironmentObject var vpnModel: CleverVpnModel
    @State private var showLocationMenu = false


    var body: some View {
        HStack(spacing: 15) {
            if let location = vpnModel.location {
                
                FlagImage(countryCode: location.code)
                    .padding(.trailing, 5)
                Text(location.label)
                    .font(.headline)
            } else {
                Image(systemName: "globe").foregroundColor(.blue)
                Text("Auto Select Adress")
                    .font(.headline)
            }
                



            if vpnModel.vpnStatus.isDisconnectedOrConnected() {
                if vpnModel.vpnStatus.isDisconnected() {
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
        .sheet(isPresented: $showLocationMenu) {
            VStack {
                if #available(iOS 16, macOS 13, *) {
                    LocationMenuView(close: $showLocationMenu)
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.medium, .large])
                    
                } else {
                    LocationMenuView(close: $showLocationMenu)
                }
                
                
#if os(iOS)
                Divider()
                HStack {
                    
                    Button {
                        vpnModel.loadLocations(fromApi: true)
                    } label : {
                        Text("Refresh")
                    }.buttonStyle(.bordered)
                }
#endif
            }
#if os(macOS)
            .frame(maxWidth: 300)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        showLocationMenu.toggle()
                    } label : {
                        Text("Close")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        vpnModel.loadLocations(fromApi: true)
                    } label : {
                        Text("Refresh")
                    }
                }

            }
#endif
        }
        .onTapGesture {
//            if vpnModel.locations.count > 0 {
                showLocationMenu.toggle()
//            }
        }
    }
    
//    #if os(macOS)
//    @ViewBuilder private var macBtn : some View {
//        Button {
//            showLocationMenu.toggle()
//        } label : {
//            Text("Close")
//        }
//        
//            ToolbarItem(placement: .confirmationAction) {
//                Button {
//                    showLocationMenu.toggle()
//                } label : {
//                    Text("Close")
//                }
//            }
//            ToolbarItem(placement: .cancellationAction) {
//                Button {
//                    showLocationMenu.toggle()
//                } label : {
//                    Text("Refresh")
//                }
//            }
//    }
//    #endif
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
    HomeCardLocation()
        .environmentObject(CleverVpnModel())
}
