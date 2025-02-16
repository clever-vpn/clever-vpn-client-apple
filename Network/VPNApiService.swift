//
//  VPNApiService.swift
//  UpVPN
//
//  Created by Himanshu on 7/10/24.
//

import Foundation

struct GetLicenceRequest: Codable {
    var id: Int?
    var appId: String
    var location: Int?
}

struct LicenceBodyData: Codable {
    var id: Int
    var licence: String;
    var location: Int?;
}

struct LicenceBodyError: Codable {
    var code: Int;
    var message: String;
}

struct GetLicenceResponse: Codable {
    var data: LicenceBodyData?
    var error: LicenceBodyError?
}


//GetLocationsResponse: [Location]

protocol VPNApiService {
    func getLicence(request: GetLicenceRequest ) async -> Result<Licence, CleverVpnError>
    func getLocations() async -> Result<[Location], ApiError>
}


class DefaultVpnApiService: VPNApiService {

    static var shared = DefaultVpnApiService()

    private var getAuthToken: () async -> String?

    private init() {
        getAuthToken = {
            guard case .success(let userInfo) = await UserInfoStore.load() else {
                return nil
            }
            return userInfo?.key
        }
    }

    private lazy var client: Client  = {
        return Client( baseURL: AppConfig.baseURL, trustAllCertificates: true, getAuthToken: self.getAuthToken)
    }()

    
    func getLicence(request: GetLicenceRequest) async -> Result<Licence, CleverVpnError> {
        
        let result: Result<GetLicenceResponse, ApiError> = await self.client.request("app-licences", method: .put, body: encodeToData(request))
            .mapError(mapClientError)
        
        switch result {
        case .success(let data):
            if let error = data.error {
               return switch error.code {
                case 1:
                       .failure(.vpnProviderFrozen)
                case 2:
                       .failure(.customerFrozen)
                case 3:
                       .failure(.noServer)
                case 4:
                       .failure(.noCustomer)
                case 5:
                       .failure(.noVpnProvider)
                default:
                       .failure(.apiError(ApiError(errorType: "unexpectedResponse", message: "unexpected response")))
                }
            }
            
            if let data = data.data {
                return .success(Licence(id: data.id, locationId: data.location, licence: data.licence))
            }
            
            return .failure(.apiError(ApiError(errorType: "unexpectedResponse", message: "unexpected response")))
            
        case .failure(let error):
            return .failure(.apiError(error))
        }
    }
    
    func getUrl() async -> String? {
        let result: Result<String, ApiError> = await self.client.request("app-url", method: .get)
            .mapError(mapClientError)
        
        if case .success(let data) = result {
            return data
        }
        
        return nil
    }
    
    func getLocations() async -> Result<[Location], ApiError> {
        return await self.client.request("key-locations", method: .get)
            .mapError(mapClientError)
    }
    
            
    
    
//
//    func signOut() async -> Result<(), ApiError> {
//        let result: Result<Empty, ApiError> = await self.client.request("sign-out", method: .post)
//            .mapError(mapClientError)
//
//        return result.map { _ in () }
//    }
//
//    func signUp(userCredsWithCode: UserCredentialsWithCode) async -> Result<(), ApiError> {
//        let result: Result<Empty, ApiError> = await self.client.request("account", method: .post,
//                                                                        body: encodeToData(userCredsWithCode))
//            .mapError(mapClientError)
//        return result.map { _ in () }
//    }
//
//    func requestCode(onlyEmail: OnlyEmail) async -> Result<(), ApiError> {
//        let result: Result<Empty, ApiError> = await self.client.request("account/send-code", method: .post,
//                                                                        body: encodeToData(onlyEmail))
//            .mapError(mapClientError)
//        return result.map { _ in () }
//    }
//
//    func getLocations() async -> Result<[Location], ApiError> {
//        return await self.client.request("locations")
//            .mapError(mapClientError)
//    }
//    
//    func newVpnSession(request: NewSession) async -> Result<Accepted, ApiError> {
//        return await self.client.request("new-vpn-session", method: .post, body: encodeToData(request))
//            .mapError(mapClientError)
//    }
//    
//    func getVpnSessionStatus(request: VpnSessionStatusRequest) async -> Result<VpnSessionStatus, ApiError> {
//        return await self.client.request("vpn-session-status", method: .post, body: encodeToData(request))
//            .mapError(mapClientError)
//    }
//    
//    func endVpnSession(request: EndSessionApi) async -> Result<Ended, ApiError> {
//        return await self.client.request("end-vpn-session", method: .post, body: encodeToData(request))
//            .mapError(mapClientError)
//    }
//
//    func processTransaction(environment: String, id: UInt64) async -> Result<(), ApiError> {
//        let result: Result<Empty, ApiError> = await self.client.request("iap/transaction/\(environment)/\(id)", method: .post)
//            .mapError(mapClientError)
//
//        return result.map { _ in () }
//    }
//
//    func getUserPlan() async -> Result<UserPlan, ApiError> {
//        return await self.client.request("plan/current")
//            .mapError(mapClientError)
//    }
}
