//
//  LastErrorStore.swift
//  CleverVpnKit
//
//  Created by bolin wu on 2025/1/16.
//

import Foundation

class LastErrorStore {
    static func save(error: LastError) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(error)
            guard let file = FileManager.networkExtensionLastErrorFileURL else {
                return
            }
            try data.write(to: file)
        }
        _ = try await task.value
    }

    static func load() async throws -> LastError? {
        let task = Task<LastError?, Error> {
            guard let file = FileManager.networkExtensionLastErrorFileURL else {
                // todo error?
                return nil
            }

            guard let data = try? Data(contentsOf: file) else {
                return nil
            }
            let error = try JSONDecoder().decode(LastError.self, from: data)
            return error
        }

        return try await task.value
    }

    static func remove() async throws {
        let task = Task {
            if let lastErrorFileURL = FileManager.networkExtensionLastErrorFileURL {
                _ = FileManager.deleteFile(at: lastErrorFileURL)
            }
        }
        await task.value
    }
}
