import SwiftUI
import ActivityKit
import WidgetKit

struct LiveOnLockScreenView: View {
    let context: ActivityViewContext<LiveOnActivityAttributes>
    @Environment(\.activityFamily) var activityFamily

    var body: some View {
        if activityFamily == .small {
            // 🔥 Apple Watch Small
            watchSmallView
        } else if activityFamily == .medium {
            // 🔥 Apple Watch Medium 또는 iPhone Lock Screen
            iPhoneLockScreenView
        } else {
            // 기본: iPhone Lock Screen
            iPhoneLockScreenView
        }
    }

    // MARK: - iPhone Lock Screen View
    private var iPhoneLockScreenView: some View {
        VStack(spacing: 20) {
            // 상단: 좌측 정보 + 로고 (우측)
            HStack(alignment: .center, spacing: 6) {
                // 좌측 영역 (친구 + 리조트 + 타이머)
                HStack(spacing: 10) {
                    // 친구 아이콘 + 숫자
                    HStack(spacing: 4) {
                        Image("img_liveactivity_friend")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text("\(context.state.liveFriendCount)")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .fixedSize(horizontal: true, vertical: false)

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

                    // 타이머
                    Text(context.attributes.liveOnStartAt, style: .timer)
                        .font(.system(size: 12, weight: .bold))
                        .lineLimit(1)
                }

                Spacer()

                // SNOWLIVE 로고 이미지 (우측)
                Image("img_liveactivity_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 10)
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
                        .minimumScaleFactor(0.6)
                        .truncationMode(.tail)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 26)
        }
        .padding(.vertical, 18)
    }

    // MARK: - Apple Watch Small View
    private var watchSmallView: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 1행: 로고 (좌측)
            Image("img_liveactivity_logo")
                .resizable()
                .scaledToFit()
                .frame(height: 8)

            // 2행: 친구 + 리조트명 + 타이머
            HStack(spacing: 6) {
                // 친구 아이콘 + 숫자
                HStack(spacing: 3) {
                    Image("img_liveactivity_friend")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                    Text("\(context.state.liveFriendCount)")
                        .font(.system(size: 11, weight: .bold))
                }

                // 리조트명
                HStack(spacing: 2) {
                    Image("img_liveactivity_pin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                    Text(context.attributes.resortName.isEmpty ? "-" : context.attributes.resortName)
                        .font(.system(size: 11))
                }

                // 타이머
                Text(context.attributes.liveOnStartAt, style: .timer)
                    .font(.system(size: 11, weight: .bold))
            }

            // 3행: 오늘 총 라이딩 + 현재 라이딩
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Text("오늘 총 라이딩")
                        .font(.system(size: 11))
                        .opacity(0.7)
                    Text("\(context.state.todayRideCount)")
                        .font(.system(size: 13, weight: .bold))
                }

                HStack(spacing: 4) {
                    Text("현재 라이딩")
                        .font(.system(size: 11))
                        .opacity(0.7)
                    Text("\(context.state.sessionRideCount)")
                        .font(.system(size: 13, weight: .bold))
                }
            }

            // 4행: 마지막 슬로프
            HStack(spacing: 4) {
                Text("마지막 슬로프")
                    .font(.system(size: 11))
                    .opacity(0.7)
                Text(lastSlopeName)
                    .font(.system(size: 11, weight: .bold))
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(12)
    }

    private var lastSlopeName: String {
        context.state.lastSlopeName.isEmpty ? "-" : context.state.lastSlopeName
    }
}