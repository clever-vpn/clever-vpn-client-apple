//
//  HomeCardDivider.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/9.

import SwiftUI

struct HomeCardDivider: View {
    @EnvironmentObject var vpnModel: CleverVpnModel


    var body: some View {

        switch vpnModel.vpnStatus {

        case  .connecting:
//            ProgressView(value: 0.5)
            IndeterminateLinearProgress()
                .padding(.horizontal, 30)
        case .connected, .reconnecting:
            HStack {
                // embeded in vstack because divider in hstack becomes vertical
                VStack {
                    Divider()
                        .padding(.leading, 30)
                        .padding(.trailing, 10)
                }
                ElapsedTimeView(startDate: vpnModel.startTime ?? Date.now)
                    .frame(minWidth: 100, maxWidth: 110)
                VStack {
                    Divider()
                        .padding(.leading, 10)
                        .padding(.trailing, 30)
                }
            }
            
        default:
            Divider()
                .padding(.horizontal, 30)

        }
    }
}

//struct IndeterminateLinearProgress: View {
//    @State private var progress: Double = 0
//
//    var body: some View {
//        ProgressView(value: progress, total: 1)
//            .progressViewStyle(LinearProgressViewStyle())
//            .onAppear {
//                // 从 0 跑到 1，然后重置，再跑……
//                withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
//                    progress = 1
//                }
//            }
//            .onChange(of: progress) { new in
//                // 当跑到 1 时，立刻重置到 0，触发下一轮动画
//                if new >= 1 {
//                    progress = 0
//                }
//            }
//    }
//}

struct IndeterminateLinearProgress: View {
    @State private var isAnimating = false

    /// 宽度比例，滑块宽度=总宽度×ratio
    var ratio: CGFloat = 0.3
    /// 动画每轮用时
    var duration: Double = 1.0

    var body: some View {
        GeometryReader { geo in
            // 背景轨道
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 4)

            // 前景滑块
            Capsule()
                .fill(Color.accentColor)
                .frame(width: geo.size.width * ratio, height: 4)
                .offset(x: isAnimating
                        ? geo.size.width
                        : -geo.size.width * ratio
                )
                .onAppear {
                    // 触发一次从 (‑ratio*width) → width 的动画
                    isAnimating = true
                }
                // 把整个 offset 的变化用无限循环的动画关联起来
                .animation(
                    .linear(duration: duration)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
        }
        .frame(height: 4)
    }
}

#Preview {
    IndeterminateLinearProgress()
        .padding(.horizontal, 30)
}

#Preview {
    HomeCardDivider().environmentObject(CleverVpnModel())
}
