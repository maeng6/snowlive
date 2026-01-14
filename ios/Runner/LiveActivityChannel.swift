import Foundation
import Flutter
import ActivityKit

final class LiveActivityChannel {
    static let channelName = "live_activity"

    static func register(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)

        channel.setMethodCallHandler { call, result in
            // iOS 16.1 미만은 바로 무시
            guard #available(iOS 16.1, *) else {
                result(nil)
                return
            }

            switch call.method {
            case "start":
                guard let args = call.arguments as? [String: Any] else { result(FlutterError(code: "ARG", message: "invalid args", details: nil)); return }
                let ms   = (args["liveOnStartAtMs"] as? NSNumber)?.int64Value ?? 0
                let today = args["todayRideCount"] as? Int ?? 0
                let session = args["sessionRideCount"] as? Int ?? 0
                let last = args["lastSlopeName"] as? String ?? "-"
                let resort = args["resortName"] as? String ?? ""
                let friends = args["liveFriendCount"] as? Int ?? 0

                print("[LiveActivityChannel] start - resort: \(resort), friends: \(friends)")

                Task {
                    do {
                        let id = try await LiveActivityManager.shared.start(
                            liveOnStartAtMs: ms,
                            todayRideCount: today,
                            sessionRideCount: session,
                            lastSlopeName: last,
                            resortName: resort,
                            liveFriendCount: friends
                        )
                        result(id)  // Flutter로 activityId 반환
                    } catch {
                        result(FlutterError(code: "START_FAILED", message: error.localizedDescription, details: nil))
                    }
                }

            case "update":
                guard let args = call.arguments as? [String: Any] else { result(FlutterError(code: "ARG", message: "invalid args", details: nil)); return }
                let id = args["activityId"] as? String ?? ""
                let today = args["todayRideCount"] as? Int ?? 0
                let session = args["sessionRideCount"] as? Int ?? 0
                let last = args["lastSlopeName"] as? String ?? "-"
                let friends = args["liveFriendCount"] as? Int ?? 0

                Task {
                    do {
                        try await LiveActivityManager.shared.update(
                            activityId: id,
                            todayRideCount: today,
                            sessionRideCount: session,
                            lastSlopeName: last,
                            liveFriendCount: friends
                        )
                        result(nil)
                    } catch {
                        result(FlutterError(code: "UPDATE_FAILED", message: error.localizedDescription, details: nil))
                    }
                }

            case "end":
                guard let args = call.arguments as? [String: Any] else { result(FlutterError(code: "ARG", message: "invalid args", details: nil)); return }
                let id = args["activityId"] as? String ?? ""

                Task {
                    do {
                        try await LiveActivityManager.shared.end(activityId: id)
                        result(nil)
                    } catch {
                        result(FlutterError(code: "END_FAILED", message: error.localizedDescription, details: nil))
                    }
                }

            case "endAll":
                Task {
                    await LiveActivityManager.shared.endAll()
                    result(nil)
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}
