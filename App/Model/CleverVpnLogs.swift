////
////  Logs.swift
////  VpnUi
////
////  Created by bolin wu on 2025/1/3.
////
//
//import CleverVpnKit
//import Combine
//import Foundation
//
//@MainActor
//public class CleverVpnLogs: ObservableObject {
//    @Published var logItems: [LogEntry] = []
//    private var task: Task<Void, any Error>? = nil
//
//    func startLog() {
//        task = Task.detached { [weak self] in
//            let logNotification = VpnApi.getlogNotification()
//            for try await logs in logNotification {
//                try Task.checkCancellation()
//                for log in logs {
//                    await self?.updateLog(log)
//                }
//                try await Task.sleep(nanoseconds: 1_000_000_000)
//            }
//        }
//    }
//
//    func stopLog() {
//        task?.cancel()
//        task = nil
//    }
//
//    private func updateLog(_ log: LogEntry) {
//        let length = logItems.count - 500
//        if length > 0 {
//            self.logItems.removeFirst(length)
//        }
//        self.logItems.append(log)
//    }
//}
