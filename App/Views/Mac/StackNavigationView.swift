//
//  StackNavigationExView.swift
//  appTest
//
//  Created by bolin wu on 2025/1/10.
//

import Foundation

import SwiftUI
import Combine

class StackNavigationModel: ObservableObject {
    @Published var pushed: [AnyView?] = []
    
    func push(_ content: AnyView) {
        let view = AnyView(content.id(UUID()))
        pushed.append(view)

    }
}

struct CurrentView: View {
    
    @EnvironmentObject var stackModel: StackNavigationModel
    
    private var defaultView: AnyView
    
    var body: some View { stackModel.pushed.last ?? defaultView }
    
    init<Content: View>(defaultView: Content) {
        self.defaultView = AnyView(defaultView)
    }
    
}

extension View {
    @ViewBuilder
    func conditionalToolbar(_ show: Bool, @ViewBuilder content: () -> ToolbarItem<Void, some View>) -> some View {
        if show {
            self.toolbar {
                content()
            }
        } else {
            self
        }
    }
}

@available(macOS, introduced: 12, obsoleted: 13)
public struct StackNavigationView<Content: View>: View {
    
    private var content: Content
    @StateObject private var stackModel = StackNavigationModel()
    
    private var canGoBack: Bool { stackModel.pushed.count > 0 }
    
    public var body: some View {
        CurrentView(defaultView: content)
                .environmentObject(stackModel)
                .conditionalToolbar(canGoBack) {
                                   return ToolbarItem(placement: .navigation) {
                                        Button(action: goBack, label: {
                                            Image(systemName: "chevron.left")
                                        })
                                        .keyboardShortcut("[", modifiers: .command)
                                    }
                }
        
//        if canGoBack {
//            view = view.toolbar {
//                ToolbarItem(placement: .navigation) {
//                    Button(action: goBack, label: {
//                        Image(systemName: "chevron.left")
//                    })
//                    .keyboardShortcut("[", modifiers: .command)
//                }
//            }
//                
//        }
//        return view
        
                
//        {
////                    if canGoBack {
//                        ToolbarItem(placement: .navigation) {
//                            Button(action: goBack, label: {
//                                Image(systemName: "chevron.left")
//                            })
//                            .keyboardShortcut("[", modifiers: .command)
//                        }
//                }
                

    }
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    
    private func goBack() {
        _ = stackModel.pushed.popLast()
    }
    
}

@available(macOS, introduced: 12, obsoleted: 13)
public struct StackNavigationLink<Label: View, Destination: View>: View {

    private var label: Label
    private var destination: Destination
    private var wrapInButton = false

    @EnvironmentObject var stackModel: StackNavigationModel

    public var body: some View {
        let action = {
            stackModel.push(AnyView(destination))
        }

        if wrapInButton {
            Button(action: action, label: { label })
        }
        else {
            label.onTapGesture(perform: action)
        }
    }

    /// Creates an instance that presents `destination`.
    public init(destination: Destination, @ViewBuilder label: () -> Label) {
        self.label = label()
        self.destination = destination
    }
}

extension StackNavigationLink where Label == Text {
    /// Creates an instance that presents `destination` when `selection` is set
    /// to `tag`, with a `Text` label generated from a title string.
    public init<S>(_ title: S, destination: Destination) where S : StringProtocol {
        self.label = Text(title)
        self.destination = destination
        self.wrapInButton = true
    }

}




struct NavigationLinkEx<Label: View, Destination: View>: View {

    let content: AnyView


    var body: some View {
        content
    }

    /// Creates an instance that presents `destination`.
    init(destination: Destination, @ViewBuilder label: () -> Label) {
        if #available(macOS 13, iOS 16,  *) {
            self.content = AnyView(NavigationLink(destination: destination, label: label))
        } else {
            self.content = AnyView(StackNavigationLink(destination: destination, label: label))
        }
        
//        self.content = AnyView(StackNavigationLink(destination: destination, label: label))

    }
}

extension NavigationLinkEx where Label == Text {
    /// Creates an instance that presents `destination` when `selection` is set
    /// to `tag`, with a `Text` label generated from a title string.
    init<S>(_ title: S, destination: Destination) where S : StringProtocol {
        if #available(macOS 13, *) {
            self.content = AnyView(NavigationLink(title, destination: destination))
        } else {
            self.content = AnyView(StackNavigationLink(title, destination: destination))
        }
    }

}

