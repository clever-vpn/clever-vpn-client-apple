//
//  Response.swift
//  UpVPN
//
//  Created by Himanshu on 7/5/24.
//

import Foundation

enum Response : Codable {
    case status(VpnStatus)
    case runtimeConfiguration(RuntimeConfiguration?)
    case licenceError(CleverVpnError?)

    init(data: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: data)
    }

    func encode() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
