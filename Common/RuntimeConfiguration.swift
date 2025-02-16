//
//  RuntimeConfiguration.swift
//  CleverVpnKit
//
//  Created by bolin wu on 2024/12/27.
//

import Foundation

struct RuntimeConfiguration: Codable {
  let tx: Int
  let rx: Int
  let handShakeTime: Int
    
//    public init(tx: Int, rx: Int, handShakeTime: Int) {
//        self.tx = tx
//        self.rx = rx
//        self.handShakeTime = handShakeTime
//    }
}


public struct Traffic: Codable {
    public let tx: Int
    public let rx: Int
    public init(tx: Int, rx: Int) {
        self.tx = tx
        self.rx = rx
    }
}
