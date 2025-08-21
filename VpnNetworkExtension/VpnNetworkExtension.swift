//
//  VpnNetworkExtension.swift
//  VpnNetworkExtension
//
//  Created by bolin wu on 2024/12/31.
//

import Foundation
import NetworkExtension
import CleverVpnKit

class PacketTunnelProvider: CleverVpnPacketTunnelProvider {
    
    override init() {
        // 方式1: 使用默认配置
//        super.init()
        
        // 方式2: 使用自定义配置（取消注释下面的代码来使用）
        
        let customConfig = CleverVpnConfiguration(
            maxRetryAttempts: 10,        // 最大重连次数
            connectionTimeout: 1200,     // 连接超时时间（毫秒）
        )
        super.init(configuration: customConfig)
        
    }
}
