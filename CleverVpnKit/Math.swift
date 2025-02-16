//
//  Math.swift
//  CleverVpnFramework
//
//  Created by bolin wu on 2024/12/16.
//

import Foundation

internal import WireGuardKit
internal import WireGuardKitGo

public class SimpleAlgorithms {

    public func fibonacci(_ n: Int) -> Int {
        var a = 1
        var b = 1
        guard n > 1 else { return a }

        (2...n).forEach { _ in
            (a, b) = (a + b, a)
        }
        return a
    }

    public func factorial(n: Int) -> Int {
        var result = 1
        if n > 0 {
            (1...n).forEach { i in
                result *= i
            }
        }
        return result
    }
    
    public func getWgVersion() -> String {
        return wgVersionEx()
//        return "1.0.0"
    }
        
        

    public init() {
        
    }
}



func wgVersionEx() -> String {
//    if let versionCString = wgVersion() {

    if let versionCString = kudpTest() {
        return String(cString: versionCString)
    } else {
        return "Unknown version"
    }
//    return "1.0.0"
}
