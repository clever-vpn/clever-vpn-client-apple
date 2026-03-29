//
//  AuthView.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/8.
//

import CleverVpnKit
import CodeScanner
import Foundation
import SwiftUI

struct AuthView: View {
    //    @EnvironmentObject var vpnModel: CleverVpnModel
    @EnvironmentObject var cleverVPNModel: VPNClient

    @State private var authKey: String = ""
    @AppStorage("userConsent") private var userConsent: Bool = false
    @State private var dataForUserConsentIsPresented = false
    @State private var isShowingScanner = false

    private var buttonDisabled: Bool {
        return !userConsent
            || cleverVPNModel.apiStatus == .connecting
            || cleverVPNModel.activateStatus == .activate
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 0)

                    VStack(spacing: 8) {
                        WelcomeView(showSpinnner: false)
                        Text("Clever VPN")
                            .font(.largeTitle.bold())

                        Text("Fast Modern VPN")
                            .font(.headline.weight(.thin))
                    }
                    .padding(.bottom, 34)

                    VStack(spacing: 18) {
                        HStack {
                            TextField("User ID", text: $authKey)
                                .padding(12)
                                .textFieldStyle(PlainTextFieldStyle())
                                .background(
                                    RoundedRectangle(cornerRadius: 9)
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
                                        .padding(10)
                                        .background(
                                            Circle()
                                                .fill(Color.gray.opacity(0.14))
                                        )
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

                        Button {
                            cleverVPNModel.activate(key: authKey)
                        } label: {
                            if cleverVPNModel.apiStatus == .connecting {
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

                        VStack(spacing: 8) {
                            Toggle(isOn: $userConsent) {
                                Text("Agree to associate device data to your account")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Button {
                                dataForUserConsentIsPresented.toggle()
                            } label: {
                                Text("View data usage details")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                            }
                            .buttonStyle(.plain)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.uSecondarySystemGroupedBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.secondary.opacity(0.14), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .frame(maxWidth: 520)
                    .disabled(cleverVPNModel.activateStatus == .activate || cleverVPNModel.apiStatus == .connecting)

                    Spacer(minLength: 0)
                }
                .frame(minHeight: proxy.size.height)
            }
            .sheet(isPresented: $dataForUserConsentIsPresented) {
                if #available(iOS 16, macOS 13, *) {
                    UserDataConsent()
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.medium, .large])
                        #if os(macOS)
                            .toolbar {
                                Button {
                                    dataForUserConsentIsPresented.toggle()
                                } label: {
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
                                    } label: {
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
            .frame(maxWidth: 400)
        #endif

    }

}

struct ScaleEffectModifier: ViewModifier {
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
        .environmentObject(vpnClient)
}
