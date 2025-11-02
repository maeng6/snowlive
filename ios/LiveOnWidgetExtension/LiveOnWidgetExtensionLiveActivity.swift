// LiveOnWidgetExtension/LiveOnWidgetExtensionLiveActivity.swift
import WidgetKit
import SwiftUI
import ActivityKit

struct LiveOnWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveOnActivityAttributes.self) { context in
            // 🔒 잠금화면/배너: 기존 파일의 LiveOnLockScreenView 사용
            LiveOnLockScreenView(context: context)
        } dynamicIsland: { context in
            // 🏝 Dynamic Island
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                        Text("Today").font(.caption2)
                        Text("\(context.state.todayRideCount)").bold()
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack {
                        Text("Last Slope").font(.caption2)
                        Text(context.state.lastSlopeName.isEmpty ? "-" : context.state.lastSlopeName)
                            .font(.headline).lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .leading) {
                        Text("Session").font(.caption2)
                        Text("\(context.state.sessionRideCount)").bold()
                    }
                }
            } compactLeading: {
                Text("\(context.state.todayRideCount)").font(.caption2).bold()
            } compactTrailing: {
                Text("\(context.state.sessionRideCount)").font(.caption2).bold()
            } minimal: {
                Text("🏂")
            }
        }
    }
}
