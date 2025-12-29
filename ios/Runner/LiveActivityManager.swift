import Foundation
import ActivityKit

// iOS 16.1+ 에서만 동작
@available(iOS 16.1, *)
final class LiveActivityManager {
    static let shared = LiveActivityManager()
    private init() {}

    // 여러 개를 동시에 켜는 상황까지 대비 (id -> Activity)
    private var activities: [String: Activity<LiveOnActivityAttributes>] = [:]

    // 시작
    func start(liveOnStartAtMs: Int64,
               todayRideCount: Int,
               sessionRideCount: Int,
               lastSlopeName: String,
               resortName: String) async throws -> String {

        // 시스템이 Live Activities를 허용하는지 확인
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            throw NSError(domain: "LiveActivity", code: -1, userInfo: [NSLocalizedDescriptionKey: "Live Activities Disabled"])
        }

        let startDate = Date(timeIntervalSince1970: TimeInterval(liveOnStartAtMs) / 1000.0)

        // 고정 속성
        let attributes = LiveOnActivityAttributes(liveOnStartAt: startDate, resortName: resortName)

        // 가변 상태
        let state = LiveOnActivityAttributes.ContentState(
            todayRideCount: todayRideCount,
            sessionRideCount: sessionRideCount,
            lastSlopeName: lastSlopeName
        )

        // 요청
        let activity = try Activity.request(attributes: attributes, contentState: state)

        let id = activity.id
        activities[id] = activity
        return id
    }

    // 업데이트
    func update(activityId: String,
                todayRideCount: Int,
                sessionRideCount: Int,
                lastSlopeName: String) async throws {
        guard let activity = activities[activityId] ?? Activity<LiveOnActivityAttributes>.activities.first(where: { $0.id == activityId }) else {
            throw NSError(domain: "LiveActivity", code: -2, userInfo: [NSLocalizedDescriptionKey: "Activity not found"])
        }

        let state = LiveOnActivityAttributes.ContentState(
            todayRideCount: todayRideCount,
            sessionRideCount: sessionRideCount,
            lastSlopeName: lastSlopeName
        )
        await activity.update(using: state)
        activities[activityId] = activity
    }

    // 종료
    func end(activityId: String) async throws {
        guard let activity = activities[activityId] ?? Activity<LiveOnActivityAttributes>.activities.first(where: { $0.id == activityId }) else {
            throw NSError(domain: "LiveActivity", code: -3, userInfo: [NSLocalizedDescriptionKey: "Activity not found"])
        }
        await activity.end(dismissalPolicy: .immediate)
        activities.removeValue(forKey: activityId)
    }
}
