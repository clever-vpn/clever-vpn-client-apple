//
//  AuthView.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/8.
//

import Foundation
import SwiftUI
import CodeScanner

struct AuthView: View {
    @EnvironmentObject var vpnModel: CleverVpnModel
    @State private var authKey: String = ""
    @AppStorage("userConsent") private var userConsent: Bool = false
    @State private var dataForUserConsentIsPresented = false
    @State private var isShowingScanner = false
    
    private var buttonDisabled: Bool {
        return !userConsent
        || vpnModel.activateStatus == .waiting
        || vpnModel.activateStatus == .activate
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 35) {
                
                VStack(spacing: 5) {
                    WelcomeView(showSpinnner: false)
                    Text("Clever VPN")
                        .font(.largeTitle.bold())
                    
                    Text("Fast Modern VPN")
                        .font(.headline.weight(.thin))
                }
                
                VStack(spacing: 20) {
                    HStack {
                    TextField("User ID", text: $authKey)
                        .padding(12)
                        .textFieldStyle(PlainTextFieldStyle())
                        .background(RoundedRectangle(cornerRadius: 9)
                            .strokeBorder(Color.gray, lineWidth: 1)
                        )
#if os(iOS)
                    //                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
#endif
              
                        #if os(iOS)
                        Button(action: {
                            isShowingScanner = true
                        }) {
                            Image(systemName: "qrcode.viewfinder")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        .buttonStyle(.plain)
                        .sheet(isPresented: $isShowingScanner) {
                            CodeScannerView(codeTypes: [.qr]) { response in
                                if case let .success(result) = response {
                                    authKey = result.string
                                    isShowingScanner = false
                                }
                            }
                        }
#endif
                        
                }

                    Toggle(isOn: $userConsent) {
                        Text("Agree to associate device data to your account")
                            .font(.caption)
                            .foregroundStyle(.blue)
                            .onTapGesture {
                                dataForUserConsentIsPresented.toggle()
                            }
                    }
                    .padding(.horizontal)


                    Button {
                        vpnModel.activate(key: authKey)
                    } label: {
                        if vpnModel.activateStatus == .waiting {
                            if #available(macOS 13, iOS 15, *) {
                                ProgressView()
                                    .modifier(ScaleEffectModifier())
                                    .padding(.vertical, 5)
                                    .frame(maxWidth: .infinity)
                            } else {
                                // on macOS 12 progress view spinner goes out of button boundary
                                Text("Login")
                                    .padding(.vertical, 5)
                                    .frame(maxWidth: .infinity)
                            }
                        } else {
                            Text("Login")
                                .padding(.vertical, 5)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                    .disabled(buttonDisabled)

                }
                .padding(.horizontal, 20)
                .disabled(vpnModel.activateStatus == .activate || vpnModel.activateStatus == .waiting)
            }.sheet(isPresented: $dataForUserConsentIsPresented) {
                if #available(iOS 16, macOS 13, *) {
                   UserDataConsent()
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.medium, .large])
                        #if os(macOS)
                        .toolbar {
                            Button {
                                dataForUserConsentIsPresented.toggle()
                            } label : {
                                Text("Close")
                            }
                        }
                        #endif

                } else {
                    UserDataConsent()
                        #if os(macOS)
                        .toolbar {
                            // on macOS 12 ESC doesnt close it, hence provide a button
                            if #unavailable(macOS 13) {
                                Button {
                                    dataForUserConsentIsPresented.toggle()
                                } label : {
                                    Text("Close")
                                }
                            }
                        }
                        #endif
                }
            }
        }
        .navigationTitle("Login")
#if os(macOS)
        .frame(maxWidth: 400).padding(.vertical, 120)
#endif
        
    }
        
}

struct ScaleEffectModifier : ViewModifier {
    // scaleEffect crashes on macOS 12 hence this modifer
    func body(content: Content) -> some View {
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

struct IconOnlyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.primary)
            .padding(8)
            .background(Color.clear)
            .clipShape(Circle())
    }
}

#Preview {
    AuthView()
        .environmentObject(CleverVpnModel())
}

