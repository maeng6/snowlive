import WidgetKit
import SwiftUI
import ActivityKit
import os

private let logger = Logger(subsystem: "com.snowlive.LiveOnWidgetExtension", category: "LA")

struct LiveOnWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveOnActivityAttributes.self) { context in
            // 🔒 Lock Screen / Banner
            LiveOnLockScreenView(context: context)
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
                        Text("Snowlive").font(.headline)
                        HStack(spacing: 12) {
                            Label("\(context.state.sessionRideCount)", systemImage: "figure.skiing.downhill")
                            if let lastRideAt = context.state.lastRideAt {
                                Text(lastRideAt, style: .relative)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Text(context.state.lastSlopeName.isEmpty ? "-" : context.state.lastSlopeName)
                            .font(.subheadline)
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
                Label("\(context.state.sessionRideCount)", systemImage: "figure.skiing.downhill")
                    .onAppear { logger.info("🟢 [DynamicIsland] compactLeading appeared") }
            } compactTrailing: {
                if let lastRideAt = context.state.lastRideAt {
                    Text(lastRideAt, style: .relative)
                        .font(.caption2)
                } else {
                    Text("-")
                }
            } minimal: {
                Text("🏂")
                    .onAppear { logger.info("🟢 [DynamicIsland] minimal appeared") }
            }
        }
    }
}
