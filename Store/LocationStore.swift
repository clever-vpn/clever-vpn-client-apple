//
//  LocationStore.swift
//  UpVPN
//
//  Created by Himanshu on 7/24/24.
//

import Foundation

class LocationStore {
    static func save(locations: [Location]) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(locations)
            guard let file = FileManager.locationsURL else {
                return
            }
            try data.write(to: file)
        }
        _ = try await task.value
    }

    static func load() async throws -> [Location] {
        let task = Task<[Location], Error> {
            guard let file = FileManager.locationsURL else {
                // todo error?
                return []
            }
            
            guard let data = try? Data(contentsOf: file) else {
                return []
            }
            let locations = try JSONDecoder().decode([Location].self, from: data)
            return locations
        }
        
        return try await task.value
    }
}
