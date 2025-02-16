# CleverVpnKit Design 
## Introduction
    CleverVpnKit is a VPN client SDK for iOS 、 macOS and macOS of Develeper ID sign.

## 设计原则：
    1. 保持简单：接口非常少，用户只需要很少的界面设计，就能实现一个VPN客户端。
    2. 易于理解：接口名非常移动，一看接口名就知道如何使用。
    3. 完整封装：封装了所有VPN客户端的功能，用户不需要关心底层实现，只关心界面呈现。
    
## 功能设计：
    1. networkExtension的封装：
        1. 继承一个CleverVpnPacketTunnelProvider类。
        2. 一个初始化函数：CleverVpnNetworkExtensionInit
    2. VPN客户端的API封装：CleverVpnClient类
        1. 身份认证：
            1. signIn
            2. signOut
            3. activate
            4. deactivate
            5. status（当前是处于登陆/激活状态， 包含状态观测器）
        2. VPN连接：
            1. connect
            2. disconnect
            3. status:(包含状态观测器)
        3. site选择
            1. sites
            2. setSite
            3. getSite
        4. log
            1. logView（包含日志观察器）
            
            
## 架构设计：
    1. 存储：都使用文件共享存储；不使用keychain，因为它在不同系统的差别太大
    2. 网络访问：networkextension 只访问vpn服务器，其他都是客户端来访问。尽量简化networkextension
    
    
    
## networkExtension的对象生命周期：
    原先的实现：
    1. WireGuardAdaptor与PacketTunnelProvider生命周期同步，
    2. VPNMonitor 与WireGuardAdaper同步；
    3. 修改了WireGuardAdapter功能，以满足VPNMonitor的重连和port的动态切换。
    
    现在的思路：
    1. 保持原先的WireGuardAdaptor不变。port动态变化，由外部实现。重现也是外部利用update来实现。
    
    了解一下upVPN的VpnOrchestrator的工作流程；
    外部操作它的接口是：
    1. startAndWait(location: location)
    2. sendCommand(Stop(reason: "client requested"))
    
### VpnOrchestrator设计： 它就是一个链接管理器：
    1. licence机制：
        1. 它应该是有状态的：
            1.licence;
            2.上次通讯时间；
            3.连续下载次数；目的是计算下载时间的最小间隔，防止频繁访问服务器。
        2. 下载错误处理：
            1. 如果没有激活码，则退出；
            2. 出现错误（比如资金不够），则退出；
        3. 下载触发点：
            1.启动阶段，如果没有licence，则下载licence，如果有，则清楚下载次数，
            2.重连阶段，每次重连前，需要刷新licence，如果满足获取条件，则下载新的licence。
        4. 下载重复次数清零时机：
            1.启动vpn时；
            2.重连成功；
    2. 重连机制：
        无限重连；
        状态机，上次连接的状态需要记住。
    3. 通讯状态监控：
    4. PacketTunnelProvider的状态，与实际状态有差别：
        
    

    
    
    
    
    
    
            
        

