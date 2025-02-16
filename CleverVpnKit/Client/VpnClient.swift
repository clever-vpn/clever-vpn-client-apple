//
//  Client.swift
//  CleverVpnKit
//
//  Created by bolin wu on 2024/12/31.
//

import Combine
import Foundation
import NetworkExtension

public var VpnApi = VpnClient.shared

public class VpnClient {
    public static let shared = VpnClient()
    private var startRequestId: String?
    private var log = VpnLogNotification()
    //    private var logEx = VpnLogEx()
    private var manager: NETunnelProviderManager?
    private func create() async throws {
        // Based on https://developer.apple.com/forums/thread/674686?answerId=663891022#663891022

        let managers = try await NETunnelProviderManager.loadAllFromPreferences()
        let manager = managers.first ?? NETunnelProviderManager()

        let providerProtocol = NETunnelProviderProtocol()
        providerProtocol.providerBundleIdentifier = Bundle.main.bundleIdentifier! + ".network-extension"
        providerProtocol.providerConfiguration = [:]
        providerProtocol.serverAddress = "dynamic"

        manager.protocolConfiguration = providerProtocol
        manager.isEnabled = true
        manager.isOnDemandEnabled = false

        let productName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") ?? "Clever VPN"
        manager.localizedDescription = productName as? String

        try await manager.saveToPreferences()
        try await manager.loadFromPreferences()
        self.manager = manager
    }
    private func enable() async throws {
        if let manager = self.manager, !manager.isEnabled {
            manager.isEnabled = true
            try await manager.saveToPreferences()
            try await manager.loadFromPreferences()
            self.manager = manager
        }
    }

    private init() {
        Logger.configureGlobal(tagged: "APP", withFilePath: FileManager.logFileURL?.path)
    }

    public func getlogNotification() -> VpnLogNotification {
        return VpnLogNotification()
    }

    public func getVpnStatus() -> VpnStatus? {
        let status = self.manager?.connection.status
        return status.map { neVPNStatusToVpnStatus($0) }
    }

    public func getVpnStatusNotification() -> VpnStatusNotification {
        return VpnStatusNotification()
    }

    public func getActivateStatus() async -> Bool {
        if case .success(let userInfo) = await UserInfoStore.load() {
            if (userInfo?.key) != nil {
                return true
            }
        }
        return false
    }

    public func activate(key: String) async -> CleverVpnError? {
        var _userInfo: UserInfo? = nil
        if case .success(let userInfo) = await UserInfoStore.load() {
            _userInfo = userInfo
        }
        //        var _licence: Licence? = nil
        //        if case.success(let licence) = await LicenceStore.load() {
        //            _licence = licence
        //        }

        let userInfo = UserInfo(key: key, locationId: _userInfo?.locationId)
        _ = await UserInfoStore.save(userInfo: userInfo)

        let appId = await getAppId()
        let result = await DefaultVpnApiService.shared.getLicence(
            request: GetLicenceRequest(
                appId: appId, location: userInfo.locationId)
        )
        
        //        let result: Result<Licence, CleverVpnError> = .success(Licence(id: 123, locationId: 1, licence: """
        //  [Interface]
        //  PrivateKey = 6M8ieabu2wvBsMpbYCO5N6zkPr/ARMyEeS2GlYcP5Eo=
        //  Address = 10.0.0.10/32, fddd:2c4:2c4:2c4::0:a/128
        //  DNS = 1.1.1.1, 1.0.0.1
        //
        //  [Peer]
        //  PublicKey = miwUh9RPALOpEMv342h4GTQXUPrajyEMGRusN2sX+jE=
        //  AllowedIPs = 0.0.0.0/0, ::/0
        //  Endpoint = 2-4.clever-vpn.xyz:52820
        //  PersistentKeepalive = 25
        //"""))

        //                let result: Result<Licence, CleverVpnError> = .success(Licence(id: 123, locationId: 1, licence: """
        //          [Interface]
        //          PrivateKey = 6M8ieabu2wvBsMpbYCO5N6zkPr/ARMyEeS2GlYcP5Eo=
        //          Address = 10.0.0.10/32, fddd:2c4:2c4:2c4::0:a/128
        //          DNS = 1.1.1.1, 1.0.0.1
        //
        //          [Peer]
        //          PublicKey = miwUh9RPALOpEMv342h4GTQXUPrajyEMGRusN2sX+jE=
        //          AllowedIPs = 0.0.0.0/0, ::/0
        //          Endpoint = 144.202.124.119:52820
        //          PersistentKeepalive = 25
        //        """))

        if case .success(let licence) = result {
            _ = await LicenceStore.save(licence: licence)
            let url = await DefaultVpnApiService.shared.getUrl()
            if url != nil && url?.isEmpty == false {
                _ = await UserInfoStore.save(userInfo: UserInfo(key: userInfo.key, locationId: userInfo.locationId, url: url))
            }
        }

        if case .failure(let failure) = result {
            await deActivate()
            return failure
        } else {
            return nil
        }

    }

    public func deActivate() async {
        // todo:
        //    delete remote licence of this appId
        _ = await UserInfoStore.delete()
        _ = await LicenceStore.delete()
    }

    public func updateUserInfo(userInfo: UserInfo) async {
        _ = await UserInfoStore.save(userInfo: userInfo)
    }

    public func start() async throws {
        if self.manager == nil {
            try await self.create()
        }
        // if another vpn app has its configuration enabled then ours is disabled
        // so when user request to connect try to enable our configuration
        try await self.enable()

        do {
            startRequestId = UUID().uuidString
            let options = ["startRequestId": startRequestId]
            wg_log(.info, message: "startTunnel: startRequestId:\(startRequestId!) ")
            try (self.manager?.connection as? NETunnelProviderSession)?.startTunnel(options: options)
        } catch let error {
            wg_log(.error, message: "cannot start: \(error)")
            throw error
        }
    }

    public func stop() {
        self.manager?.connection.stopVPNTunnel()
    }

    public func getTraffic() async -> Traffic? {
        guard let session = self.manager?.connection as? NETunnelProviderSession else { return nil }
        if let response = try? await session.sendProviderMessage(request: Request.getRuntimeConfiguration) {
            switch response {
            case .runtimeConfiguration(let config):
                if let config = config {
                    return Traffic(tx: config.tx,rx: config.rx)
                }
            default:
                return nil
            }
        }
        return nil
    }

    public func getUserInfo() async -> UserInfo? {
        if case .success(let userInfo) = await UserInfoStore.load() {
            return userInfo
        } else {
            return nil
        }
    }

    public func getLocations(fromApi: Bool = false) async -> [Location]? {
        if fromApi {
            if case .success(let locations) = await DefaultVpnApiService.shared.getLocations() {
                try? await LocationStore.save(locations: locations)
            } else {
                return nil
            }
        }

        return try? await LocationStore.load()
    }

    public func getLastError() async -> CleverVpnError? {
        guard let startRequestId = startRequestId else { return nil }
        guard let lastError = try? await LastErrorStore.load() else { return nil }
        guard lastError.startRequestId == startRequestId else { return nil }
        return lastError.error
    }

    private func getAppId() async -> String {
        return await AppIdStore.load()
    }

}
