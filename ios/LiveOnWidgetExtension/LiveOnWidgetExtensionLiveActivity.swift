import WidgetKit
import SwiftUI
import ActivityKit
import os

private let logger = Logger(subsystem: "com.snowlive.LiveOnWidgetExtension", category: "LA")

struct LiveOnWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveOnActivityAttributes.self) { context in
            // 🔒 Lock Screen / Banner
            VStack(spacing: 6) {
                Text("Snowlive Live").font(.headline)
                Text(context.attributes.liveOnStartAt, style: .time)
                Text("today \(context.state.todayRideCount) / session \(context.state.sessionRideCount)")
                Text("last: \(context.state.lastSlopeName.isEmpty ? "-" : context.state.lastSlopeName)")
            }
            .padding(8)
            .onAppear {
                logger.info("🔵 [LockScreen] view appeared")
                logger.info("🧩 [LockScreen] attributes: \(String(describing: context.attributes))")
                logger.info("🧩 [LockScreen] state: today=\(context.state.todayRideCount), session=\(context.state.sessionRideCount), last=\(context.state.lastSlopeName)")
            }
            .onDisappear {
                logger.info("⚫️ [LockScreen] view disappeared")
            }

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 4) {
                        Text("🏔 Snowlive Session").font(.headline)
                        Text("Today \(context.state.todayRideCount)")
                        Text("Session \(context.state.sessionRideCount)")
                        Text("Last: \(context.state.lastSlopeName.isEmpty ? "-" : context.state.lastSlopeName)")
                    }
                    .onAppear {
                        logger.info("🟣 [DynamicIsland] expanded")
                        logger.info("🧩 [DynamicIsland] attributes: \(String(describing: context.attributes))")
                        logger.info("🧩 [DynamicIsland] state: today=\(context.state.todayRideCount), session=\(context.state.sessionRideCount), last=\(context.state.lastSlopeName)")
                    }
                    .onDisappear {
                        logger.info("⚫️ [DynamicIsland] collapsed")
                    }
                }
            } compactLeading: {
                Text("\(context.state.todayRideCount)")
                    .onAppear { logger.info("🟢 [DynamicIsland] compactLeading appeared") }
            } compactTrailing: {
                Text("\(context.state.sessionRideCount)")
                    .onAppear { logger.info("🟢 [DynamicIsland] compactTrailing appeared") }
            } minimal: {
                Text("🏂")
                    .onAppear { logger.info("🟢 [DynamicIsland] minimal appeared") }
            }
        }
    }
}
