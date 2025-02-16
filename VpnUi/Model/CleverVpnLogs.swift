//
//  Logs.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/3.
//

import Foundation
import Combine
import CleverVpnKit

@MainActor
public class CleverVpnLogs: ObservableObject {
    @Published var logItems: [LogEntry] = []
    private var task: Task<Void, Never>? = nil
    
    
    private func appendLog(_ log: LogEntry) {
        logItems.append(log)
    }
    
    func startLog() {
        task = Task {
            let logNotification = VpnClient.shared.getlogNotification()
              do {
                  for try await logs in logNotification {
                      for log in logs {
                              appendLog(log)
                      }
                      try? await Task.sleep(nanoseconds: 1_000_000_000)
                  }
                  
              } catch {
                  print("Error receiving logs: \(error)")
              }
          }

    }
    
    func stopLog() {
        task?.cancel()
        logItems.removeAll()
    }
}

//public class CleverVpnLogs: ObservableObject {
//    @Published var logItems: [LogEntry] = []
//    private var cancellable: AnyCancellable?
//    
//    deinit {
//        cancellable?.cancel()
//    }
//    
//    private func appendLog(_ log: LogEntry) {
//        logItems.append(log)
//    }
//    
//    func startLog() {
//        cancellable = VpnClient.shared.logSubscriber.sink { [weak self] log in
//            self?.appendLog(log)
//        }
//    }
//    
//    func stopLog() {
//        cancellable?.cancel()
//        logItems.removeAll()
//    }
//}
