//
//  MenuBarExtraView.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/8.
//

import Foundation
import SwiftUI

#if os(macOS)

    @available(macOS 13, *)
    struct MenuBarExtraView: View {
        @State private var showContextMenu = false
        @State private var isHoveredOpen = false
        @State private var isHoveredMenu = false
        @State private var isHoveredQuit = false

        @EnvironmentObject private var vpnModel: CleverVpnModel

        @Environment(\.openWindow) var openWindow
        @Environment(\.dismiss) private var dismiss

        var body: some View {
            VStack(spacing: 10) {
                VStack {
                    switch vpnModel.activateStatus {
                    case .activate:
                        HStack {
                            Spacer()
                            Button {
                                openWindow(id: "main")
                                dismiss()

                            } label: {
                                Image(systemName: "square.and.arrow.up")

                            }.buttonStyle(.automatic)
                                .background(isHoveredOpen ? Color.gray.opacity(0.5) : Color.clear)
                                .onHover { hovering in
                                    isHoveredOpen = hovering
                                }

                            Button {
                                showContextMenu.toggle()
                            } label: {
                                Image(systemName: "ellipsis")

                            }.buttonStyle(.automatic)
                                .background(isHoveredMenu ? Color.gray.opacity(0.5) : Color.clear)
                                .onHover { hovering in
                                    isHoveredMenu = hovering
                                }
                                .popover(isPresented: $showContextMenu) {
                                    VStack {
                                        LaunchAtLogin.Toggle()
                                        Button(action: {
                                            NSApplication.shared.terminate(nil)
                                            //                                                                          showContextMenu.toggle()
                                        }) {
                                            Text("Quit App")
                                                .frame(maxWidth: .infinity)
                                        }.onHover { hovering in
                                            isHoveredQuit = hovering
                                        }.background(isHoveredQuit ? Color.gray.opacity(0.5) : Color.clear)

                                    }.padding()
                                }

                            //                            .overlay(alignment: .bottom) {
                            //                                if showContextMenu {
                            //                                    VStack {
                            //                                        Button(action: {
                            //                                            print("选项 1")
                            //                                            showContextMenu.toggle()
                            //                                        }) {
                            //                                            HStack {
                            //                                                Image(systemName: "star.fill")
                            //                                                Text("选项 1")
                            //                                            }
                            //                                            .foregroundColor(.black)
                            //                                        }
                            //                                        Button(action: {
                            //                                            print("选项 1")
                            //                                            showContextMenu.toggle()
                            //                                        }) {
                            //                                            HStack {
                            //                                                Image(systemName: "star.fill")
                            //                                                Text("选项 1")
                            //                                            }
                            //                                            .foregroundColor(.black)
                            //                                        }
                            //
                            //                                    }
                            //                                }
                            //                            }

                            //                        Menu {
                            //                            Button(action: {
                            //                                openWindow(id: "main")
                            //                            }) {
                            //                                Label("Option 1", systemImage: "1.circle")
                            //                            }
                            //
                            //                            Button(action: {
                            //                                openWindow(id: "main")
                            //                            }) {
                            //                                Label("Option 2", systemImage: "2.circle")
                            //                            }
                            //
                            //                            Button(action: {
                            //                                openWindow(id: "main")
                            //                            }) {
                            //                                Label("Option 3", systemImage: "3.circle")
                            //                            }
                            //                        } label: {
                            //                            Image(systemName: "ellipsis")
                            //                                .padding()
                            //                                .background(Color.gray.opacity(0.2))
                            //                                .cornerRadius(8)
                            //                        }.menuStyle(.borderlessButton)
                            //                            .buttonStyle(.plain)
                            //                        .menuIndicator(.hidden)

                        }

                        ZStack {
                            Rectangle()
                                .fill(Color.uSystemGroupedBackground)
                                .ignoresSafeArea()

                            HomeCard()

                        }
                    case .notActivate:
                        VStack(spacing: 20) {
                            VStack(spacing: 5) {
                                WelcomeView(showSpinnner: false)
                                Text("Clever VPN")
                                    .font(.largeTitle.bold())

                                Text("Fast Modern VPN")
                                    .font(.headline.weight(.thin))
                            }
                            Button {
                                openWindow(id: "main")
                                dismiss()
                            } label: {
                                Text("Activate")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 5)
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                            .padding(.bottom, 20)
                        }
                    case .waiting:
                        Text("Waiting")
                    }
                }.frame(maxWidth: .infinity)
                    .padding(10)
            }
        }
    }

#endif

#if os(macOS)
    #Preview {
        if #available(macOS 13, *) {
            Text("No Preview")

            //        MenuBarExtraView(i)
        } else {
            Text("No Preview")
        }
    }
#endif
