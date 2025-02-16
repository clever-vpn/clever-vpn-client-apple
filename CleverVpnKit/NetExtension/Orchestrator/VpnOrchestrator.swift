//
//  VpnOrchestrator.swift
//  CleverVpnKit
//
//  Created by bolin wu on 2024/12/23.
//

import Foundation
import NetworkExtension
internal import WireGuardKit
internal import WireGuardKitGo

extension Int {
    var sec: UInt64 {
        return (1_000_000_000) * UInt64(self)
    }
}

//enum OrchestratorError: Error, Codable {
////    case wireguardAdapterError(WireGuardAdapterError)
//    case wireguardAdapterError(String)
//    case licenceError(CleverVpnError)
//    case error(String)
//}

//extension OrchestratorError: CustomStringConvertible {
//    var description: String {
//        return switch self {
//        case .wireguardAdapterError(let wireGuardAdapterError):
//            wireGuardAdapterError.description
//        case .licenceError(let licenceError):
//            licenceError.description
//        case .error(let string):
//            string
//        }
//    }
//}

struct TSnap {
    var bytes: Int
    var t: Int

    init() {
        bytes = 0
        t = 0
    }
}

enum ConnType: Int {
    case     connKUDP,
             connTCP,
             connTLS,
             connUDP
//             connWG
}

class ConnState {
    var handShakeTime: Int
    var rx: TSnap
    var tx: TSnap
    var connType: ConnType
    var connStartTime: Int
    var running: Bool {
        didSet {
            if running {
                UserDefaults.standard.set(connType.rawValue, forKey: "lastConnType")
            }
        }
    }

    func reset() {
        
    }
    
    init() {
        handShakeTime = 0
        rx = TSnap()
        tx = TSnap()
        connType = ConnType.connKUDP
        connStartTime = 0
        running = false
    }

    
    func getConntype() async -> ConnType {
        return await _getConnType(next: false, type: connType)
//        let type = await getProtocolType()
//        switch type {
//        case .auto:
//            return connType
//        case .kudp:
//            return .connKUDP
//        case .tcp:
//            if connType == .connTCP || connType == .connTLS {
//                return connType
//            }
//            return .connTCP
//        case .udp:
//            return .connUDP
//        }
    }
    
    func getNextConnType(type: ConnType) async -> ConnType {
        return await _getConnType(next: true, type: type)
//        let type1 = await getProtocolType()
//        switch type1 {
//        case .auto:
//            return nextConnType(type: type)
//        case .kudp:
//            return .connKUDP
//        case .tcp:
//            let nextType = nextConnType(type: type)
//            if nextType == .connTCP || nextType == .connTLS {
//                return nextType
//            }
//            return .connTCP
//        case .udp:
//            return .connUDP
//        }
        
        }
    
    private func _getConnType(next: Bool, type: ConnType) async -> ConnType {
        let type1 = await getProtocolType()
        switch type1 {
        case .auto:
            return next ? nextConnType(type: type) : type
        case .kudp:
            return .connKUDP
        case .tcp:
            let type2 = next ? nextConnType(type: type) : type
            if type2 == .connTCP || type2 == .connTLS {
                return type2
            }
            return .connTCP
        case .udp:
            return .connUDP
        }
    }
        
   
    private func nextConnType(type: ConnType) -> ConnType {
            return switch type {
            case .connKUDP:
                    .connTCP
            case .connTCP:
                    .connTLS
            case .connTLS:
                    .connUDP
            case .connUDP:
                    .connKUDP
            }
        }
    
    private func getProtocolType() async -> ProtocolType {
        if case .success(let userInfo) = await UserInfoStore.load() {
            if let userInfo = userInfo {
                return userInfo.protocolType
            }
        }
        
        return .auto
    }
        
        
        
}

actor VpnOrchestrator {
    
    private var packetTunnelProvider: NEPacketTunnelProvider
    private var startRequestId: String? = nil
    private var licenceManager = LicenceManager()
    private var connState: ConnState = ConnState()
    private var connError: CleverVpnError?
    private lazy var wgAdapterAsync: WGAdapterAsync = {
        return WGAdapterAsync(wireguardAdapter: WireGuardAdapter(with: self.packetTunnelProvider) { logLevel, message in
                        wg_log(logLevel.osLogLevel, message: message)
                    })
    }()
    
    private var checkTask: Task<Void, Never>? = nil
    private func startCheckTask() {
        checkTask?.cancel()
        checkTask = Task {
            while true {
                // 检查任务是否被取消
                if Task.isCancelled {
                    print("Task was cancelled")
                    return
                }
                do {
                    let connType = await updateConnState()
                    if let connType = connType {
                       let result = await connect(connType: connType, retry: true)
                        if case .failure(let error) = result {
                            connError = error
                            await cancelTunnel(error: error)
                        }
                    }
                    try await Task.sleep(nanoseconds: 1.sec)
                }catch {
                    wg_log(.error, message: "VPNMonitor error happen!")
                }
            }
        }
    }
    private func stopCheckTask() {
        checkTask?.cancel()
        checkTask = nil
    }
    
    // if need connect, return connType; or, return nil
    private func updateConnState()async -> ConnType?  {
        guard let (stamp, tx, rx) = await getRuntimeCfg() else {
            return nil
        }
        
        let s = self.connState
        let now = Int(Date().timeIntervalSince1970)

        // update handShakeTime/tx/rx
        s.handShakeTime = stamp
        if tx != s.tx.bytes {
            s.tx.bytes = tx
            s.tx.t = now
        }
        if rx != s.rx.bytes {
            s.rx.bytes = rx
            s.rx.t = now
        }
        
        if s.running {
            // stop: 我利用双向的keepalive来判断是否链接正常
            // 1. handsshake > 190s OR
            // 2. nowSecond > rx.t + 30s   keepalive设置为25s
            if s.handShakeTime < now - 190 ||
                (s.rx.t < now - 30) {
                s.running = false
                wg_log(.error, message: "VPNMonitor  kudp(\(s.connType)) disconnected! ")
                
                return s.connType
            }
            return nil
        } else {
            //running
            // handShakeTime > connStartTime
            // rx.t > connStartTime
            if s.handShakeTime > s.connStartTime ||
                s.rx.t > s.connStartTime
            {
                s.running = true
                await licenceManager.refresh()
                wg_log(.info, message: "VPNOrChestrator (\(s.connType)) connected! ")
                return nil
            }else {
                // 5s后切换连接方式
                if now > s.connStartTime + 10 {
                    return await s.getNextConnType(type: s.connType)
                }
                return nil
            }
        }
    }
    
    private func connect(connType: ConnType, retry: Bool = false) async -> Result<(), CleverVpnError>{
        let resultLicence = await licenceManager.getLicence()
        guard case .success(let licence)  = resultLicence else {
            return resultLicence.map{ _ in  ()}
        }
        
        var count = retry ? 8 : 16
        var result: Result<(), CleverVpnError> = .success(())
        var type = connType
        while count > 0 {
            result = await _connect(licence: licence, connType: type, retry: retry)
            if case .success = result {
                connError = nil
                await initConnState(connType: type)
                break
            }
            count -= 1
            type = await connState.getNextConnType(type: type)
        }
        
        return result
    }
    
//    private func _connect(connType: ConnType, retry: Bool = false) async -> Result<(), CleverVpnError>{
//        let result = await licenceManager.getLicence()
//        guard case .success(let licence)  = result else {
//            return result.map{ _ in ()}
//        }
//        
//        guard let host = await licenceManager.getLicenceHost(licence: licence) else {
//            return .failure(.invalid)
//        }
//
//        var kudpSchemes: [ConnType:String] = [:]
//        switch connType {
//        case .connKUDP:
//            kudpSchemes[.connKUDP] = "kudp"
//            fallthrough
//        case .connTCP:
//            kudpSchemes[.connTCP] = "tcp"
//            fallthrough
//        case .connTLS:
//            kudpSchemes[.connTLS] = "tls"
//            for (key, scheme)  in kudpSchemes {
//                do {
//                    kudpTurnOff()
//                    try await Task.sleep(nanoseconds: 100_000_000)
//                    if kudpTurnOn(scheme, host) == -1 {
//                        let message = "kudpTurnOn error"
//                        wg_log(.error, message: message)
//                        continue
//                    }
//
//                    let p = kudpGetListenPort()
//                    
//                    let _licence = await licenceManager.updateLicenceEndpoint(licence: licence, endpoint: "127.0.0.1:\(p)")
//                    return await wgConnect(connType: key, licence: _licence, retry: retry)
//
//                } catch {
//                    wg_log(.error, message: "VPNMonitor kudp exception!")
//                }
//            }
//            fallthrough
//        case .connUDP:
//            let port = Int.random(in: 1000...35000)
//            let _licence = await licenceManager.updateLicencePort(licence: licence, port: port)
//            return await wgConnect(connType: .connUDP, licence: _licence, retry: retry)
//        }
//
//    }
//    
    
    private func _connect(licence: String, connType: ConnType, retry: Bool = false) async -> Result<(), CleverVpnError>{
//        let result = await licenceManager.getLicence()
//        guard case .success(let licence)  = result else {
//            return result.map{ _ in ()}
//        }
        
        guard let host = await licenceManager.getLicenceHost(licence: licence) else {
            return .failure(.invalid)
        }
        
        //        var kudpSchemes: [ConnType:String] = [:]
        switch connType {
        case .connKUDP, .connTCP, .connTLS:
            let scheme: String?  = switch connType {
            case .connKUDP:
                "kudp"
            case .connTCP:
                "tcp"
            case .connTLS:
                "tls"
            default:
                nil
            }
            if let scheme = scheme {
                
                do {
                    kudpTurnOff()
//                    try await Task.sleep(nanoseconds: 100_000_000)
                    if kudpTurnOn(scheme, host) == -1 {
                        let message = "kudpTurnOn error"
                        wg_log(.error, message: message)
                        return .failure(.invalid)
                    }
                    
                    let p = kudpGetListenPort()
                    
                    let _licence = await licenceManager.updateLicenceEndpoint(licence: licence, endpoint: "127.0.0.1:\(p)")
                    return await wgConnect(connType: connType, licence: _licence, retry: retry)
                    
                } catch {
                    wg_log(.error, message: "VPNMonitor kudp exception!")
                    return .failure(.invalid)
                }
            }
        case .connUDP:
            let port = Int.random(in: 1000...35000)
            let _licence = await licenceManager.updateLicencePort(licence: licence, port: port)
            return await wgConnect(connType: .connUDP, licence: _licence, retry: retry)
        }
        
        return .failure(.invalid)
    }
    
    private func wgConnect(connType: ConnType, licence: String, retry: Bool) async ->Result<(), CleverVpnError> {
        if let tunnelCfg = try? TunnelConfiguration(fromWgQuickConfig: licence) {
            var result: Result<(), CleverVpnError>
            if retry {
                result = await wgAdapterAsync.update(tunnelConfiguration: tunnelCfg).mapError {
                    .tunnelError($0.description) }
            }else {
                result = await wgAdapterAsync.start(tunnelConfiguration: tunnelCfg).mapError {
                    .tunnelError($0.description) }
            }
           
            return result
        }else {
            return .failure(.invalid)
        }
    }
    
    private func initConnState(connType: ConnType) async {
        
       let (stamp, tx, rx) = await getRuntimeCfg() ?? (0,0,0)
        
        let s = self.connState
        let now = Int(Date().timeIntervalSince1970)
        
        s.connStartTime = now
        s.handShakeTime = stamp
        (s.tx.t, s.tx.bytes) = (now, tx)
        (s.rx.t, s.rx.bytes) = (now, rx)
        s.running = false
        s.connType = connType
    }
    
    init(packetTunnelProvider: NEPacketTunnelProvider) {
//        (commandStream, continuation) = AsyncStream.makeStream(
//            of: Any.self,
//            bufferingPolicy: .unbounded
//        )
        self.packetTunnelProvider = packetTunnelProvider

//        Task {
//            await self.startMain()
//        }
    }
    
    deinit {
        checkTask?.cancel()
        checkTask = nil
    }
    
    
    
    nonisolated func startTunnel(id: String?) async -> Result<(), CleverVpnError> {
        await setStartRequestId(id: id)
        await licenceManager.refresh()
        let result = await connect(connType: connState.getConntype())
        if case .success = result {
            await startCheckTask()
        }
        
        return result
    }
    
    private func setStartRequestId(id: String?) {
        startRequestId = id
    }
    
    func stopTunnel() async -> Result<(), CleverVpnError> {
        stopCheckTask()
        
        let result = await wgAdapterAsync.stop()
            .mapError {CleverVpnError.tunnelError($0.description)}
        
        return result
    }
    
    func cancelTunnel(error: CleverVpnError) async {
        stopCheckTask()
        let errorNotifier = await ErrorNotifier(startRequestId: startRequestId)
        await errorNotifier.notify(error)
        packetTunnelProvider.cancelTunnelWithError(error)
    }
    
    func getLicenceError() -> CleverVpnError? {
        return connError
    }
    
    func getRuntimeCfg() async -> (stamp: Int, tx:Int, rx:Int)? {
        guard let setting = await wgAdapterAsync.getRuntimeConfiguration() else {
            return nil
        }

        var rx = 0, tx = 0, stamp = 0
        let pattern = "last_handshake_time_sec=([0-9]*).*^tx_bytes=([0-9]*).*^rx_bytes=([0-9]*)"
        do {
            let regex = try NSRegularExpression(pattern: pattern,
                                                options:[NSRegularExpression.Options.dotMatchesLineSeparators,NSRegularExpression.Options.anchorsMatchLines])
            
            let matches = regex.matches(in: setting, range: NSRange(setting.startIndex..., in: setting))

            if let match = matches.first {
                for i in 1..<match.numberOfRanges {
                    let range = match.range(at: i)
                    if let swiftRange = Range(range, in: setting) {
                        guard let v = Int(String(setting[swiftRange])) else {
                            continue
                        }
                        switch i {
                        case 1:
                            stamp = v
                        case 2:
                            tx = v
                        case 3:
                            rx = v
                        default:
                            break
                        }
                    }
                }

            }else {
                return nil
            }
        } catch {
            return nil
        }
        return (stamp, tx, rx)
    }
        
    func getStatus() async -> VpnStatus {
        // todo
        return VpnStatus.connected
        
    }
    
}
