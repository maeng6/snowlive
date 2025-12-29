import SwiftUI
import ActivityKit
import WidgetKit

struct LiveOnLockScreenView: View {
    let context: ActivityViewContext<LiveOnActivityAttributes>

    var body: some View {
        VStack(spacing: 23) {
            // 상단: 로고 (좌측) + 리조트명/타이머 (우측)
            HStack(alignment: .center, spacing: 0) {
                // SNOWLIVE 로고 이미지 (좌측 끝 정렬)
                Image("img_liveactivity_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 10)

                // 리조트명 + 타이머 (우측 끝 정렬)
                HStack(spacing: 6) {
                    // 핀 아이콘 + 리조트명
                    HStack(spacing: 2) {
                        Image("img_liveactivity_pin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text("휘닉스파크")
                            .font(.system(size: 12))
                            .lineLimit(1)
                    }
                    // 타이머
                    Text(context.attributes.liveOnStartAt, style: .timer)
                        .font(.system(size: 12, weight: .bold))
                        .monospacedDigit()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            // 하단: 3개 컬럼 (라이딩 횟수, 라이브온 중인 친구, 마지막 슬로프)
            HStack(alignment: .top, spacing: 28) {
                // 라이딩 횟수
                VStack(alignment: .leading, spacing: 4) {
                    Text("라이딩 횟수")
                        .font(.system(size: 12))
                        .opacity(0.7)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    Text("\(context.state.sessionRideCount)")
                        .font(.system(size: 20, weight: .bold))
                }

                // 라이브온 중인 친구
                VStack(alignment: .leading, spacing: 4) {
                    Text("라이브온 중인 친구")
                        .font(.system(size: 12))
                        .opacity(0.7)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    Text("\(context.state.liveFriendCount)")
                        .font(.system(size: 20, weight: .bold))
                }

                // 마지막 라이딩 슬로프
                VStack(alignment: .leading, spacing: 5) {
                    Text("마지막 라이딩 슬로프")
                        .font(.system(size: 12))
                        .opacity(0.7)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    Text(lastSlopeName)
                        .font(.system(size: 18, weight: .bold))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 26)
        .padding(.vertical, 18)
    }

    private var lastSlopeName: String {
        context.state.lastSlopeName.isEmpty ? "-" : context.state.lastSlopeName
    }
}
