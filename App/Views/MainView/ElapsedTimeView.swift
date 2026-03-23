//
//  ElapsedTimeVIew.swift
//  VpnUi
//
//  Created by bolin wu on 2025/1/9

import SwiftUI

struct ElapsedTimeView: View {
    let startDate: Date

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            Text(elapsedTimeText(now: context.date))
                .font(.headline.weight(.semibold))
                .padding(.horizontal)
                .padding(.vertical, 1)
                .background(
                    Capsule().stroke()
                )
                .frame(maxHeight: 40)
                // minimumScaleFactor to prevent ... (dots) in displayed text
                .minimumScaleFactor(0.5)
        }
    }

    private func elapsedTimeText(now: Date) -> String {
        let elapsed = max(0, Int(now.timeIntervalSince(startDate)))
        let hours = elapsed / 3600
        let minutes = (elapsed % 3600) / 60
        let seconds = elapsed % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    ElapsedTimeView(startDate: Date.now)
}
