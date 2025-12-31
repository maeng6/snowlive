import SwiftUI
import ActivityKit
import WidgetKit

struct LiveOnLockScreenView: View {
    let context: ActivityViewContext<LiveOnActivityAttributes>

    var body: some View {
        VStack(spacing: 20) {
            // 상단: 로고 (좌측) + 친구 아이콘/숫자 + 리조트명/타이머 (우측)
            HStack(alignment: .center, spacing: 0) {
                // SNOWLIVE 로고 이미지 (좌측)
                HStack {
                    Image("img_liveactivity_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 10)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 우측 영역 (친구 + 리조트 + 타이머)
                HStack(spacing: 12) {
                    // 친구 아이콘 + 숫자
                    HStack(spacing: 4) {
                        Image("img_liveactivity_friend")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text("\(context.state.liveFriendCount)")
                            .font(.system(size: 12, weight: .bold))
                    }

                    // 리조트명
                    HStack(spacing: 2) {
                        Image("img_liveactivity_pin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text(context.attributes.resortName.isEmpty ? "-" : context.attributes.resortName)
                            .font(.system(size: 12))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                    }

                    // 타이머 (HStack 밖으로)
                    Text(context.attributes.liveOnStartAt, style: .timer)
                        .font(.system(size: 12, weight: .bold))
                        .monospacedDigit()
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 26)

            // 하단: 3개 컬럼 (오늘 총 라이딩 횟수, 현재 라이딩 횟수, 마지막 슬로프)
            HStack(alignment: .top, spacing: 28) {
                // 오늘 총 라이딩 횟수
                VStack(alignment: .leading, spacing: 4) {
                    Text("오늘 총 라이딩")
                        .font(.system(size: 12))
                        .opacity(0.7)
                        .lineLimit(1)
                    Text("\(context.state.todayRideCount)")
                        .font(.system(size: 20, weight: .bold))
                }
                .fixedSize(horizontal: true, vertical: false)

                // 현재 라이딩 횟수
                VStack(alignment: .leading, spacing: 4) {
                    Text("현재 라이딩")
                        .font(.system(size: 12))
                        .opacity(0.7)
                        .lineLimit(1)
                    Text("\(context.state.sessionRideCount)")
                        .font(.system(size: 20, weight: .bold))
                }
                .fixedSize(horizontal: true, vertical: false)

                // 마지막 라이딩 슬로프
                VStack(alignment: .leading, spacing: 5) {
                    Text("마지막 슬로프")
                        .font(.system(size: 12))
                        .opacity(0.7)
                        .lineLimit(1)
                    Text(lastSlopeName)
                        .font(.system(size: 18, weight: .bold))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 26)
        }
        .padding(.vertical, 18)
    }

    private var lastSlopeName: String {
        context.state.lastSlopeName.isEmpty ? "-" : context.state.lastSlopeName
    }
}