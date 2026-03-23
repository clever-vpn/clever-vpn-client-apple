// //
// //  SystemExtensionManager.swift
// //  ProtonVPN - Created on 07/12/2020.
// //
// //  Copyright (c) 2019 Proton Technologies AG
// //
// //  This file is part of ProtonVPN.
// //
// //  ProtonVPN is free software: you can redistribute it and/or modify
// //  it under the terms of the GNU General Public License as published by
// //  the Free Software Foundation, either version 3 of the License, or
// //  (at your option) any later version.
// //
// //  ProtonVPN is distributed in the hope that it will be useful,
// //  but WITHOUT ANY WARRANTY; without even the implied warranty of
// //  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// //  GNU General Public License for more details.
// //
// //  You should have received a copy of the GNU General Public License
// //  along with ProtonVPN.  If not, see <https://www.gnu.org/licenses/>.
// //

// import Foundation
// import SystemExtensions

// import os.log

// let installSE = ({() in
//     if #available(macOS 10.15, *) {
//         var request: SystemExtensionRequest?
//         return { () in
//             let appId = Bundle.main.bundleIdentifier!
//             let providerBundleIdentifier = "\(appId).network-extension"
//             request = SystemExtensionRequest.install(bunderId: providerBundleIdentifier, stateChange: {(state: SystemExtensionRequest.State) -> Void in
//                 switch state {
//                 case .failed(let error):
// //                    wg_log(.error, message: "install systemextension error \(error)")
//                     os_log(.error, "install systemextension error \(error)")

//                 default:
// //                    wg_log(.error, message: "install systemextension ok")
//                     os_log("install systemextension ok")

//                 }
//                 return
//             })
//             let extensionManager = OSSystemExtensionManager.shared
//             extensionManager.submitRequest(request!.request)

//         }

//     } else {
//         return { () in
//             return
//         }
//     }
// })()

// public enum SystemExtensionResult {
//     /// The extension was not previously on the system, and has been installed.
//     case installed
//     /// An earlier version of the extension was installed, and has now been upgraded.
//     case upgraded
//     /// The same version of the extension was installed, and no action was taken.
//     case alreadyThere
//     /// An error occurred while trying to perform the installation or upgrade.
//     case failed(Error)
// }

// /// Wrapper class for `OSSystemExtensionRequest` that lets us keep track of individual requests more easily.
// /// Every call to a delegate function is routed through the `stateChangeCallback` property. This callback is
// /// generated uniquely for every request in the `SystemExtensionManager`, so we know the state of each
// /// installation request individually.
// @available(macOS 10.15, *)
// public class SystemExtensionRequest: NSObject {
//     typealias StateChangeCallback = ((State) -> Void)

//     let action: Action
//     let request: OSSystemExtensionRequest
//     let stateChangeCallback: StateChangeCallback

//     let uuid = UUID()

//     enum Action {
//         case install
//         case uninstall
//     }

//     enum State {
//         /// We have told sysextd we want our extension to replace an existing one in the system.
//         case replacing
//         /// Request has been received, but is waiting on user action to proceed.
//         case userActionRequired
//         /// Request has completed successfully.
//         case succeeded(OSSystemExtensionRequest.Result)
//         /// Request has been cancelled by the application. This can happen for a couple of reasons:
//         /// - Most likely, an existing extension with the same (or greater) version is already installed.
//         /// - The system asked if the application wants to replace an extension that is not recognized.
//         case cancelled
//         /// Request has been superseded by another one (user requested another sysext install).
//         case superseded
//         /// Request has failed with an error.
//         case failed(Error)
//     }

//     /// Only opts to replace an extension if the version is higher, or if a testing flag is set in defaults.
// //    func shouldExtension(_ existing: ExtensionInfo, beReplacedBy newExtension: ExtensionInfo) -> Bool {
// //        existing < newExtension || manager.propertiesManager.forceExtensionUpgrade
// //    }

//     required init(action: Action,
//                   request: OSSystemExtensionRequest,
//                   stateChange: @escaping StateChangeCallback
//                   /*manager: SystemExtensionManager*/ ) {
//         self.action = action
//         self.request = request
//         self.stateChangeCallback = stateChange
// //        self.manager = manager
//     }

// //    static func install(type: SystemExtensionType,
// //                        manager: SystemExtensionManager,
// //                        stateChange: @escaping StateChangeCallback) -> Self {
//     static func install(bunderId: String,
//                         stateChange: @escaping StateChangeCallback) -> Self {
// //        let result = Self(action: .install,
// //                          request: .activationRequest(forExtensionWithIdentifier: type.rawValue,
// //                                                      queue: SystemExtensionManager.requestQueue),
// //                          stateChange: stateChange,
// //                          manager: manager)

//         let result = Self(action: .install,
//                           request: .activationRequest(forExtensionWithIdentifier: bunderId,
//                                                       queue: DispatchQueue.main),
//                           stateChange: stateChange)
//         result.request.delegate = result
//         return result
//     }

// //    static func uninstall(type: SystemExtensionType,
// //                          manager: SystemExtensionManager,
// //                          stateChange: @escaping StateChangeCallback) -> Self {
//     static func uninstall(bunderId: String,
//                           stateChange: @escaping StateChangeCallback) -> Self {
// //        let result = Self(action: .uninstall,
// //                          request: .deactivationRequest(forExtensionWithIdentifier: type.rawValue,
// //                                                        queue: SystemExtensionManager.requestQueue),
// //                          stateChange: stateChange,
// //                          manager: manager)
//         let result = Self(action: .uninstall,
//                           request: .deactivationRequest(forExtensionWithIdentifier: bunderId,
//                                                         queue: DispatchQueue.main),
//                           stateChange: stateChange)
//         result.request.delegate = result
//         return result
//     }

//     deinit {
// //        wg_log(.debug, message: "Deinit request \(uuid.uuidString) for \(request.identifier)")
//         os_log(.debug, "Deinit request \(self.uuid.uuidString) for \(self.request.identifier)")
    
// //        log.debug("Deinit request \(uuid.uuidString) for \(request.identifier)")
//     }
// }

// @available(macOS 11, *)
// extension SystemExtensionRequest: OSSystemExtensionRequestDelegate {
//     public func request(_ request: OSSystemExtensionRequest,
//                         actionForReplacingExtension existing: OSSystemExtensionProperties,
//                         withExtension ext: OSSystemExtensionProperties) -> OSSystemExtensionRequest.ReplacementAction {
//         os_log("system-extension: call replace")
//         assert(existing.bundleIdentifier == ext.bundleIdentifier,
//                "Extensions have mismatched identifiers? (\(existing.bundleIdentifier) and \(ext.bundleIdentifier))")

// //        let shouldReplace = shouldExtension(.init(version: existing.bundleShortVersion,
// //                                                  build: existing.bundleVersion,
// //                                                  bundleId: existing.bundleIdentifier),
// //                                            beReplacedBy: .init(version: ext.bundleShortVersion,
// //                                                                build: ext.bundleVersion,
// //                                                                bundleId: ext.bundleIdentifier))

//         let shouldReplace = false

//         // Don't call stateChangeCallback(.cancelled) here, we do that when sysextd calls us again
//         // with `request(_:didFailWithError:)`.
//         guard shouldReplace else { return .cancel }

//         stateChangeCallback(.replacing)
//         return .replace
//     }

//     public func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
//         os_log("system-extension: call user approval")
//         stateChangeCallback(.userActionRequired)
//     }

//     public func request(_ request: OSSystemExtensionRequest, didFailWithError error: Error) {

//         guard let sysextError = error as? OSSystemExtensionError else {
//             os_log("system-extension: call error \(error.localizedDescription)")

//             stateChangeCallback(.failed(error))
//             return
//         }

//         os_log("system-extension: call error:OSSystemExtensionError \(sysextError.code.rawValue)")
//         os_log("system-extension: call error:OSSystemExtensionError \(sysextError.errorUserInfo)")

//         switch sysextError.code {
//         case .requestCanceled:
//             stateChangeCallback(.cancelled)
//         case .requestSuperseded:
//             stateChangeCallback(.superseded)
//         default:
//             stateChangeCallback(.failed(sysextError))
//         }

// //        manager.outstandingRequests.remove(self)
//     }

//     public func request(_ request: OSSystemExtensionRequest, didFinishWithResult result: OSSystemExtensionRequest.Result) {
//         os_log("system-extension: call finish \(result.rawValue)")

//         stateChangeCallback(.succeeded(result))

// //        manager.outstandingRequests.remove(self)
//     }
// }
