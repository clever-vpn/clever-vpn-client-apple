//
//  LogView.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/3.
//

import CleverVpnKit
import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct MyLogDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }

    var text: String

    init(logItems: [LogEntry] = []) {
        text = ""
        for log in logItems {
            text.append("\(log.level):  \(log.message)\n")
        }
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
            let text = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.text = text
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8)!
        return FileWrapper(regularFileWithContents: data)
    }
}

struct LogView: View {
    //    @EnvironmentObject var logModel: CleverVpnLogs
    @EnvironmentObject var cleverVPNLogModel: VPNLogModel

    @State private var isPresented = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ScrollViewReader { proxy in

            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(cleverVPNLogModel.logList) { log in
                        Text(log.attribedMessage)
                    }
                }.padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
            .navigationTitle("Logs")
            .onAppear {
                cleverVPNLogModel.setViewGateOpen(true)
            }
            .onDisappear {
                cleverVPNLogModel.setViewGateOpen(false)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        isPresented.toggle()
                    }
                    .fileExporter(
                        isPresented: $isPresented,
                        document: MyLogDocument(logItems: cleverVPNLogModel.logList),
                        contentType: .plainText,
                        defaultFilename: "clever-vpn-log.txt"
                    ) { result in
                        switch result {
                        case .success(let url):
                            alertMessage = "File saved to: \(url.path)"
                            showAlert = true
                        case .failure(let error):
                            alertMessage = "Failed to save file: \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Export Result"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }

                }
            }
            .onChange(of: cleverVPNLogModel.logList) { _ in
                if let lastMessageIndex = cleverVPNLogModel.logList.last {
                    withAnimation {
                        proxy.scrollTo(lastMessageIndex.id, anchor: .bottom)
                    }
                }
            }
            .onAppear {
                if let lastMessageIndex = cleverVPNLogModel.logList.last {
                    withAnimation {
                        proxy.scrollTo(lastMessageIndex.id, anchor: .bottom)
                    }
                }
            }
        }

    }
}

//struct LogView_Previews: PreviewProvider {
//    static var previews: some View {
//        LogView()
//    }
//}

#Preview {
    return LogView().environmentObject(logModel)
}
