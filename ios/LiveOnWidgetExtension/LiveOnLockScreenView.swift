import SwiftUI
import ActivityKit
import WidgetKit

struct LiveOnLockScreenView: View {
    let context: ActivityViewContext<LiveOnActivityAttributes>

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 메인 컨텐츠
            HStack(spacing: 16) {
                // 왼쪽: 세션 라이딩 횟수
                VStack(spacing: 4) {
                    Text("\(context.state.sessionRideCount)")
                        .font(.system(size: 32, weight: .bold))
                    Text("라이딩")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()
                    .frame(height: 50)

                // 오른쪽: 마지막 슬로프 정보
                VStack(alignment: .leading, spacing: 6) {
                    // X분 전 라이딩 슬로프 : 슬로프명
                    HStack(spacing: 4) {
                        Image(systemName: "mountain.2.fill")
                            .font(.caption)
                        Text(slopeDisplayString())
                            .font(.subheadline)
                            .lineLimit(1)
                    }

                    // 경과 시간
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .font(.caption2)
                        Text(context.attributes.liveOnStartAt, style: .timer)
                            .font(.caption)
                            .monospacedDigit()
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // 오른쪽 위: 라이브 중인 친구 수
            if context.state.liveFriendCount > 0 {
                HStack(spacing: 3) {
                    Image(systemName: "person.2.fill")
                        .font(.caption2)
                    Text("\(context.state.liveFriendCount)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.15))
                .cornerRadius(10)
                .padding(.top, 8)
                .padding(.trailing, 12)
            }
        }
    }

    /// 슬로프 표시 문자열 (예: "마지막 라이딩 슬로프 : 곤돌라")
    private func slopeDisplayString() -> String {
        let slopeName = context.state.lastSlopeName.isEmpty ? "-" : context.state.lastSlopeName
        return "마지막 라이딩 슬로프 : \(slopeName)"
    }
}
