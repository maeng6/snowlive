import ActivityKit
import Foundation

public struct LiveOnActivityAttributes: ActivityAttributes {

    // 현재 상태(라이브 중 실시간 갱신되는 값들)
    public struct ContentState: Codable, Hashable {
        public var todayRideCount: Int        // 오늘 전체 주행 횟수
        public var sessionRideCount: Int      // 현재 세션 내 주행 횟수
        public var lastSlopeName: String      // 마지막으로 지난 슬로프 이름
        public var lastRideAt: Date?          // 마지막 라이딩 시간
        public var liveFriendCount: Int       // 현재 라이브 중인 친구 수

        public init(todayRideCount: Int, sessionRideCount: Int, lastSlopeName: String, lastRideAt: Date? = nil, liveFriendCount: Int = 0) {
            self.todayRideCount = todayRideCount
            self.sessionRideCount = sessionRideCount
            self.lastSlopeName = lastSlopeName
            self.lastRideAt = lastRideAt
            self.liveFriendCount = liveFriendCount
        }
    }

    // 변하지 않는 속성(라이브 시작 시 고정값)
    public var liveOnStartAt: Date
    public var resortName: String

    public init(liveOnStartAt: Date, resortName: String = "") {
        self.liveOnStartAt = liveOnStartAt
        self.resortName = resortName
    }
}