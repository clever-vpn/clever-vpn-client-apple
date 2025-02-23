//
//  ModelData.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/2.
//

import CleverVpnKit
import Foundation

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

    private var statusTask: Task<Void, Never>?
    private var trafficTask: Task<Void, Never>?

    private var starting: Bool = false

    private var logTask: Task<Void, Error>? = nil

    var location: Location? {
        if let id = userInfo?.locationId {
            return locations.first(where: { $0.id == id })
        } else {
            return nil
        }
    }

    public func loadUserInfo() {
        Task {
            if let userInfo0 = await VpnClient.shared.getUserInfo() {
                userInfo = userInfo0
            }
        }
    }
    public func loadLocations(fromApi: Bool = false) {
        Task {
            if let locations0 = await VpnClient.shared.getLocations(fromApi: fromApi) {
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
            let activateStatus0 = await VpnClient.shared.getActivateStatus()
            if activateStatus0 {
                activateStatus = .activate
            } else {
                activateStatus = .notActivate
            }
        }

        statusTask = Task {
            for await status in VpnClient.shared.getVpnStatusNotification() {
                vpnStatus = status
                switch status {
                case .connected:
                    startTime = Date.now
                case .disconnected:
                    lastError = await VpnClient.shared.getLastError()
                default:
                    break
                }

            }
        }

        trafficTask = Task {
            while true {
                if let traffic0 = await VpnClient.shared.getTraffic() {
                    traffic = traffic0
                }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }

    deinit {
        statusTask?.cancel()
        trafficTask?.cancel()
    }

    func setLocation(selectedLocation: Location?) {
        Task {
            await VpnClient.shared.updateLocation(location: selectedLocation)
            loadUserInfo()
        }
    }

    func setProtocolType(protocolType: ProtocolType) {
        Task {
            await VpnClient.shared.updateProtocolType(protocolType: protocolType)
            loadUserInfo()
        }
    }

    func activate(key: String) {
        // 模拟提交激活码的逻辑
        if key.isEmpty {
            lastError = CleverVpnError.noKey
        } else {
            Task {
                if let error0 = await VpnClient.shared.activate(key: key) {
                    lastError = error0
                } else {
                    activateStatus = .activate
                    refresh()

                }
            }
        }

    }

    func deActivate() {
        Task {
            activateStatus = .waiting
            await VpnClient.shared.deActivate()
            activateStatus = .notActivate
        }
    }

    func refreshVpnStatus() {
        if let status = VpnClient.shared.getVpnStatus() {
            vpnStatus = status
        }
    }

    func turnOn(_ on: Bool) {
        if on {
            Task {
                if !starting {
                    starting = true

                    do {
                        traffic = Traffic(tx: 0, rx: 0)
                        try await VpnClient.shared.start()

                    } catch {
                        message = "Failed to start VPN: \(error)"
                    }

                    starting = false

                }
            }
        } else {
            VpnClient.shared.stop()
        }
    }

}

//func load<T: Decodable>(_ filename: String) -> T {
//    let data: Data
//
//    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
//        else {
//            fatalError("Couldn't find \(filename) in main bundle.")
//    }
//
//    do {
//        data = try Data(contentsOf: file)
//    } catch {
//        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
//    }
//
//    do {
//        let decoder = JSONDecoder()
//        return try decoder.decode(T.self, from: data)
//    } catch {
//        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
//    }
//}
