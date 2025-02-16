// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Foundation
import NetworkExtension
import os
internal import WireGuardKit

open class CleverVpnPacketTunnelProvider: NEPacketTunnelProvider {
    
    var vpnOrchestrator: VpnOrchestrator!
    
    override init() {
        os_log("init PacketTunnelProvider")
        super.init()
        
        defer {
            self.vpnOrchestrator = VpnOrchestrator(packetTunnelProvider: self)
        }
    }
    
    
    //    private lazy var adapter: WireGuardAdapter = {
    //        return WireGuardAdapter(with: self) { logLevel, message in
    //            wg_log(logLevel.osLogLevel, message: message)
    //        }
    //    }()
    
    override public func startTunnel(options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        let startRequestId = options?["startRequestId"] as? String
        Logger.configureGlobal(tagged: "NET", withFilePath: FileManager.logFileURL?.path)
        wg_log(.info, message: "Starting tunnel from the " + (startRequestId == nil ? "OS directly, rather than the app" : "app"))
        os_log("Connect start at %{public}@", log: OSLog.default, type: .info, "\(Date.now)")

        
        Task {
            let errorNotifier = await ErrorNotifier(startRequestId: startRequestId)
            let result = await self.vpnOrchestrator.startTunnel(id: startRequestId)
            
            // todo log outcome?
            switch result {
            case .success():
                os_log("Connect end at %{public}@", log: OSLog.default, type: .info, "\(Date.now)")
//                os_log("\(Date.now) connect end")
                completionHandler(nil)
            case .failure(let orcaError):
                await errorNotifier.notify(orcaError)
                completionHandler(orcaError)
            }
        }
        
    }
    
    override public func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        wg_log(.info, staticMessage: "Stopping tunnel")
        
        Task {
            await ErrorNotifier.removeLastErrorFile()
            let result = await self.vpnOrchestrator.stopTunnel()
            if case .failure(let orcaError) = result {
                wg_log(.error, message: "Failed to stop WireGuard adapter: \(orcaError.localizedDescription)")
            }
            
            completionHandler()
            
            // From upstream WireGuard project / MIT license
#if os(macOS)
            // HACK: This is a filthy hack to work around Apple bug 32073323 (dup'd by us as 47526107).
            // Remove it when they finally fix this upstream and the fix has been rolled out to
            // sufficient quantities of users.
            exit(0)
#endif
        }
    }
    
    override public func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)? = nil) {
        if let handler = completionHandler {
            if let request = try? Request(data: messageData) {
                switch request {
                case .status:
                    Task {
                        let vpnState = await self.vpnOrchestrator.getStatus()
                        let response = try? Response.status(vpnState).encode()
                        handler(response)
                    }
                case .getRuntimeConfiguration:
                    Task {
                        var response : Data? = nil
                        if let cfg = await self.vpnOrchestrator.getRuntimeCfg() {
                            response = try? Response.runtimeConfiguration(RuntimeConfiguration(tx: cfg.tx, rx: cfg.rx, handShakeTime: cfg.stamp)).encode()
                        }
                        handler(response)
                    }
                case .licenceError:
                    Task {
                        let licenceError = await self.vpnOrchestrator.getLicenceError()
                        
                        let response = try? Response.licenceError(licenceError).encode()
                        handler(response)
                    }
                }
            } else {
                handler(nil)
            }
        }
    }
}

extension WireGuardLogLevel {
    var osLogLevel: OSLogType {
        switch self {
        case .verbose:
            return .debug
        case .error:
            return .error
        }
    }
}
