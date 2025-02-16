//
//  VpnLogNotification.swift
//  CleverVpnKit
//
//  Created by bolin wu on 2025/1/4.
//

import Foundation
import Combine

//
//class VpnLog {
//    private let subject = PassthroughSubject<LogEntry, Never>()
//    private var subscribers: Int = 0
//    private var logTask: Task<Void, Error>? = nil
//    private var logHelper: LogViewHelper?
//    
//    var subscriber: AnyPublisher<LogEntry, Never> {
//        return subject.handleEvents(receiveSubscription: { [weak self] _ in
//            if let me = self {
//                me.subscribers += 1
//                if me.subscribers > 0 {
//                    me.startLog()
//                }
//            }
//        }, receiveCancel: { [weak self] in
//            if let me = self {
//                me.subscribers -= 1
//                if me.subscribers == 0 {
//                    me.stopLog()
//                }
//            }
//        }).eraseToAnyPublisher()
//    }
//    
//    deinit {
//        if logTask != nil {
//            logTask?.cancel()
//        }
//        
//        logHelper = nil
//    }
//    
//    func startLog() {
//        logHelper = LogViewHelper(logFilePath: FileManager.logFileURL?.path)
//        if logTask == nil {
//            logTask = Task {
//                while true {
//                    if Task.isCancelled {
//                        break
//                    }
//                    try? await Task.sleep(nanoseconds: 1.sec)
////                    wg_log(.error, message: "Log: \(Date())")
//                    
//                    for log in await logHelper?.asyncFetchLogEntriesSinceLastFetch() ?? [] {
//                       await sendLog(log)
//                    }
//                }
//            }
//        }
//    }
//    
//    @MainActor func sendLog(_ log: LogEntry) {
//        subject.send(log)
//    }
//    
//    func stopLog() {
//        if logTask != nil {
//            logTask?.cancel()
//            logTask = nil
//        }
//        logHelper = nil
//    }
//}

public class VpnLogNotification: AsyncSequence {
    private var logHelper = LogViewHelper(logFilePath: FileManager.logFileURL?.path)
    public typealias Element = [LogEntry]
    public func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(logHelper: logHelper)
    }

public    struct AsyncIterator: AsyncIteratorProtocol {
        private var logHelper: LogViewHelper?


        init(logHelper: LogViewHelper?) {
            self.logHelper = logHelper
        }

        public mutating func next() async throws -> [LogEntry]? {
            guard let logHelper = logHelper  else { return nil }
            var items: [LogEntry] = []
            items = await logHelper.asyncFetchLogEntriesSinceLastFetch()
            while items.isEmpty {
                try await Task.sleep(nanoseconds: 1.sec)
                items = await logHelper.asyncFetchLogEntriesSinceLastFetch()
                print(items)
            }
            
            return items
        }
    }
}
