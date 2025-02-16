//
//  ErrorNotifier.swift
//  UpVPN
//
//  Created by Himanshu on 7/15/24.
//
// Based on Sources/WireGuardNetworkExtension/ErrorNotifier.swift
// from github.com/wireguard-apple
// Copyright WireGuard LLC / MIT License


import Foundation

class ErrorNotifier {
    let startRequestId: String?

    init(startRequestId: String?) async {
        self.startRequestId = startRequestId
        await ErrorNotifier.removeLastErrorFile()
    }

    func notify(_ error: CleverVpnError) async {
        guard let startRequestId = startRequestId else { return }
        try? await LastErrorStore.save(error: LastError(startRequestId: startRequestId, error: error))
    }

    static func removeLastErrorFile() async {
        try? await LastErrorStore.remove()
    }
}
