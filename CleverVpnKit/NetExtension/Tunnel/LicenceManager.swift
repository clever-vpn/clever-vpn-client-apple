//
//  LicenceManager.swift
//  CleverVpnKit
//
//  Created by bolin wu on 2024/12/25.
//

import Foundation
internal import WireGuardKit

let endpointPattern = #"Endpoint = ([^:]+):(\d+)"#

actor LicenceManager {
    private var retries: Int = 0
    private var apiCounts: Int = 0
    private var lastApiRequestTime: Int = 0
    //    private var userInfo: UserInfo?
    //    private var licence: Licence?
    //    private var licenceError: LicenceError?

    init() {
        //        self.retries = 0
        //        self.lastApiRequestTime = 0
    }

    // clear retries:
    func refresh() {
        retries = 0
        lastApiRequestTime = 0
        apiCounts = 0
        //        userInfo = nil
        //        licence = nil
        //        licenceError = nil
    }

    //utils

    func updateLicencePort(licence: String, port: Int) -> String {
        return _updateLicenceEndpoint(licence: licence, template: "Endpoint = $1:\(port)")
    }

    func updateLicenceEndpoint(licence: String, endpoint: String) -> String {
        return _updateLicenceEndpoint(licence: licence, template: "Endpoint = \(endpoint)")
    }

    private func _updateLicenceEndpoint(licence: String, template: String) -> String {
        let regex = try? NSRegularExpression(
            pattern: endpointPattern, options: [])
        if let match = regex?.firstMatch(
            in: licence, options: [],
            range: NSRange(
                licence.startIndex..<licence.endIndex, in: licence))
        {
            let matchRange = match.range
            var modifiedLicence = licence

            if let swiftRange = Range(matchRange, in: licence) {
                modifiedLicence.replaceSubrange(
                    swiftRange,
                    with: regex!.replacementString(
                        for: match, in: licence, offset: 0,
                        template: template))
                return modifiedLicence
            }
        }

        return licence
    }

    func getLicenceHost(licence: String) -> String? {
        let regex = try? NSRegularExpression(
            pattern: endpointPattern, options: [])
        if let match = regex?.firstMatch(
            in: licence, options: [],
            range: NSRange(
                licence.startIndex..<licence.endIndex, in: licence))
        {
            let hostRange = match.range(at: 1)

            // 转换为 Swift 的 Range 类型
            if let swiftRange = Range(hostRange, in: licence) {
                // 提取第一个捕获组的值
                return String(licence[swiftRange])
            }

        }
        return nil
    }

    func getLicence() async -> Result<String, CleverVpnError> {
        
        guard let userInfo = await getUserInfo() else {
            return .failure(.noKey)
        }
        guard userInfo.key != nil else {
            return .failure(.noKey)
        }

        // first, 我们优先从本地获取licence，如果本地不能获取，则从服务器中获取
        var licence: Licence? = nil
        if case .success(let _licence) = await LicenceStore.load() {
            licence = _licence
        }

        retries += 1
        if retries == 1 && licence != nil && licence?.locationId == userInfo.locationId {
            return .success(licence!.licence)
        }

        // other, 根据时间和时间间隔决定是否从api获取licence.
        let now = Int(Date().timeIntervalSince1970)
        if licence == nil
            || lastApiRequestTime == 0
            || now > (lastApiRequestTime + apiCounts * 5)
        {
            apiCounts += 1
            let result = await getLicenceFromApi(userInfo: userInfo)
            if case .failure(let failure) = result {
                if case .apiError(_) = failure {
                    if licence != nil && retries < 20 {
                        return .success(licence!.licence)
                    }
                }
            }

            return result

        } else {
            return .success(licence!.licence)
        }

    }

    private func getLicenceFromApi(userInfo: UserInfo) async -> Result<String, CleverVpnError> {
        var licence: Licence? = nil
        if case .success(let _licence) = await LicenceStore.load() {
            licence = _licence
        }
        let appId = await AppIdStore.load()
        let result = await DefaultVpnApiService.shared.getLicence(
            request: GetLicenceRequest(
                id: licence?.id, appId: appId, location: userInfo.locationId)
        )

        lastApiRequestTime = Int(Date().timeIntervalSince1970)

        switch result {
        case .success(let _licence):
            _ = await LicenceStore.save(licence: _licence)
            return .success(_licence.licence)
        case .failure(let error):
            if case .apiError(_) = error {
            } else {
                _ = await LicenceStore.delete()
            }

            return .failure(error)
        }
    }

    private func getUserInfo() async -> UserInfo? {
        if case .success(let userInfo) = await UserInfoStore.load() {
            return userInfo
        }
        return nil
    }

    //    func getTunnelConfiguration() async -> Result<TunnelConfiguration, LicenceError> {
    //        let result = await getLicence()
    //        if case .failure(let failure) = result {
    //            return .failure(failure)
    //        }
    //
    //        if case .success(let _licence) = result {
    //            let cfg = try? TunnelConfiguration(fromWgQuickConfig: _licence.licence)
    //            if let cfg = cfg {
    //                return .success(cfg)
    //            }
    //        }
    //
    //        return .failure(.invalid)
    //    }
    //
    //    func getLicenceError() -> LicenceError? {
    //        return licenceError
    //    }

}
