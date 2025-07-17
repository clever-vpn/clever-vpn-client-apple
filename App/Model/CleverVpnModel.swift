//
//  ModelData.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/2.
//

import CleverVpnKit
import Foundation
import OSLog

enum ActivateStatus {
    case activate
    case notActivate
    case waiting
}

@MainActor
public class CleverVpnModel: ObservableObject {
    @Published var traffic = Traffic(tx: 0, rx: 0)
    @Published var message: String = ""
    @Published var appUUID: String = ""
    @Published var activateStatus: ActivateStatus = .waiting
    @Published var lastError: CleverVpnError? = nil
    @Published var vpnStatus: VpnStatus = .disconnected
    @Published var startTime: Date? = nil
    @Published var locations: [Location] = []
    @Published var userInfo: UserInfo? = nil

    private var statusTask: Task<Void, any Error>?
    private var trafficTask: Task<Void, any Error>?

    var location: Location? {
        if let id = userInfo?.locationId {
            return locations.first(where: { $0.id == id })
        } else {
            return nil
        }
    }

    public func loadUserInfo() {
        Task {
            if let userInfo0 = await VpnApi.getUserInfo() {
                userInfo = userInfo0
            }
        }
    }
    public func loadLocations(fromApi: Bool = false) {
        Task {
            if let locations0 = await VpnApi.getLocations(fromApi: fromApi) {
                locations = locations0
            }
        }
    }

    private func refresh() {
        loadUserInfo()
        loadLocations()
    }

    public init() {
        loadLocations()
        loadUserInfo()

        Task {
            let ok = await VpnApi.getActivateStatus()
            if ok {
                activateStatus = .activate
            } else {
                activateStatus = .notActivate
            }
        }

        statusTask = Task.detached { [weak self] in
            for await status in VpnApi.getVpnStatusNotification() {
                try Task.checkCancellation()
                var _lastError: CleverVpnError? = nil
                if status == .disconnected {
                    _lastError = await VpnApi.getLastError()
                }
                await self?.updateVpnStatus(status, _lastError)
            }
        }

    }

    private func updateVpnStatus(_ status: VpnStatus, _ error: CleverVpnError?) {
        vpnStatus = status
        switch status {
        case .connected:
            startTime = Date.now
        case .disconnected:
            lastError = error
        default:
            break
        }
    }

    deinit {
        statusTask?.cancel()
        trafficTask?.cancel()
    }

    func setLocation(selectedLocation: Location?) {
        Task {
            await VpnApi.updateLocation(location: selectedLocation)
            loadUserInfo()
        }
    }

    func setProtocolType(protocolType: ProtocolType) {
        Task {
            await VpnApi.updateProtocolType(protocolType: protocolType)
            loadUserInfo()
        }
    }

    func activate(key: String) {
        // 模拟提交激活码的逻辑
        if key.isEmpty {
            lastError = CleverVpnError.noKey
        } else {
            Task {
                lastError = await
                    (Task.detached {
                        return await VpnApi.activate(key: key)
                    }).value

                if lastError == nil {
                    activateStatus = .activate
                    refresh()
                }
            }

        }
    }

    func deActivate() {
        Task {
            activateStatus = .waiting
            await VpnApi.deActivate()
            activateStatus = .notActivate
        }
    }

    func refreshVpnStatus() {
        if let status = VpnApi.getVpnStatus() {
            vpnStatus = status
        }
    }

    func turnOn(_ on: Bool) {
        if on {
            Task {
                if vpnStatus.isDisconnected() {
                    do {
                        traffic = Traffic(tx: 0, rx: 0)
                        try await VpnApi.start()
                        startTrafficTask()
                    } catch {
                        message = "Failed to start VPN: \(error)"
                    }
                }
            }
        } else {
            VpnApi.stop()
            stopTrafficTask()
        }
    }
    private func startTrafficTask() {
        stopTrafficTask()
        trafficTask = Task.detached { [weak self] in
            while true {
                try Task.checkCancellation()
                let traffic0 = await VpnApi.getTraffic() ?? Traffic(tx: 0, rx: 0)
                await self?.updateTraffic(traffic0)
                try await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }

    private func updateTraffic(_ traffic0: Traffic) {
        traffic = traffic0
    }

    private func stopTrafficTask() {
        trafficTask?.cancel()
        trafficTask = nil
    }

}
