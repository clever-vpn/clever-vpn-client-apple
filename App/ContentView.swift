//
//  ContentView.swift
//  VpnUi
//
//  Created by bolin wu on 2024/12/31.
//

import SwiftUI
import CleverVpnKit




//struct ContentView: View {
//    @EnvironmentObject var vpnModel: CleverVpnModel
//    @State private var activationCode: String = ""
//    @State private var message: String = ""
//    private var toggleTitle: String {
//        vpnModel.isOn ? "ON" : "OFF"
//    }
//    
//    var body: some View {
////        @Bindable var vpnModel = vpnModel
//        NavigationView {
//            VStack(spacing: 20) {
//                Text(vpnModel.activateStatus ? "Activated" : "Not Activated")
//                    .font(.title)
//                    .foregroundColor(vpnModel.activateStatus ? .green : .red).padding(.top, 40)
//                Text(vpnModel.message)
//                    .font(.title)
//                    .foregroundColor(.red)
//                Text("Enter Activation Code")
//                    .font(.title)
//                
//                TextField("Activation Code", text: $vpnModel.key)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding(.horizontal, 20)
//                
//                Button(action: {
//                    vpnModel.submitActivationCode()
//                }) {
//                    Text("Submit")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(width: 200, height: 50)
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                }
//                
//                Toggle(isOn: $vpnModel.isOn) {
//                    Text(toggleTitle)
//                        .font(.headline)
//                }
//                .padding(.horizontal, 20)
//                .onChange(of: vpnModel.isOn) { newValue in
//                    vpnModel.turnOn(newValue)
//                }
//                
//                Button(action: {
//                    Task {
//                        vpnModel.getAppId()
//                    }
//                }){
//                    Text("appUUID")
//                        .font(.headline)
//                }
//                
//                Text(vpnModel.appUUID)
//                    .font(.headline)
//
//                Image("StatusBarIconDimmed")
//                    
//                    
//                
//                Spacer()
//                NavigationLink("Show Logs") {
//                    LogView()
//                }
//            }
//        }
//        .padding()
//    }
//    
//    
//
//}

struct ContentView: View {
    @EnvironmentObject var vpnModel: CleverVpnModel
    @State private var isLastErrorPresented = false
    var body: some View {
        VStack {
            switch vpnModel.activateStatus {
            case .waiting:
                WelcomeView()
            case .notActivate:
                AuthView()
            case .activate:
                MainView()
            }

        }
        .onReceive(vpnModel.$lastError) { error in
            if let error = error, !error.description.isEmpty {
                isLastErrorPresented = true
            }
        }
        .alert(
            "Clever VPN Error",
            isPresented: $isLastErrorPresented,
            presenting: vpnModel.lastError?.description
        ) { error in
            Button(role: .cancel) {
               vpnModel.lastError = nil
            } label: {
                Text("OK")
            }
        } message: { error in
            Text(error)
        }

    }
    
    

}


#Preview {
    ContentView().environmentObject(CleverVpnModel()).environmentObject(CleverVpnLogs())
}
