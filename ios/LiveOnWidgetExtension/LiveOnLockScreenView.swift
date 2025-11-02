import SwiftUI
import ActivityKit
import WidgetKit

struct LiveOnLockScreenView: View {
    let context: ActivityViewContext<LiveOnActivityAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "play.circle.fill")
                Text(context.attributes.liveOnStartAt, style: .time)
                Text("•")
                Text(Date(), style: .timer).monospacedDigit()
            }
            .font(.subheadline)

            HStack(spacing: 12) {
                Label("오늘 \(context.state.todayRideCount)", systemImage: "calendar")
                Label("세션 \(context.state.sessionRideCount)", systemImage: "clock")
            }
            .font(.subheadline)

            HStack(spacing: 6) {
                Image(systemName: "mountain.2.fill")
                Text("직전: \(context.state.lastSlopeName)").lineLimit(1)
            }
            .font(.subheadline)
        }
        .padding(.horizontal, 10)
    }
}
