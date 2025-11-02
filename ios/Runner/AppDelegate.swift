import UIKit
import Flutter
import GoogleMaps
import ActivityKit

@main
@objc class AppDelegate: FlutterAppDelegate {

  /// Live Activity 인스턴스 보관 (activityId -> Activity<LiveOnActivityAttributes>)
  var liveActivities: [String: Any] = [:]

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {

    // ✅ Google Maps API Key
    GMSServices.provideAPIKey("YOUR_API_KEY")

    // ✅ 플러터 루트 VC 확보
    guard let controller = self.window?.rootViewController as? FlutterViewController else {
      assertionFailure("❌ rootViewController is not FlutterViewController")
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    print("✅ AppDelegate didFinishLaunching, controller ready")

    // ============================
    // 1) 배터리 절약 모드 채널
    // ============================
    let batteryChannel = FlutterMethodChannel(
      name: "detect_battery_saver",
      binaryMessenger: controller.binaryMessenger
    )
    batteryChannel.setMethodCallHandler { (call, result) in
      print("📨 [battery] received:", call.method)
      if call.method == "isBatterySaverOn" {
        result(ProcessInfo.processInfo.isLowPowerModeEnabled)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    print("🔌 battery channel registered")

    // ============================
    // 2) Live Activity 채널
    // ============================
    print("🔌 registering live_activity channel")
    let liveActivityChannel = FlutterMethodChannel(
      name: "live_activity",
      binaryMessenger: controller.binaryMessenger
    )
    liveActivityChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      print("📨 [live_activity] received:", call.method)

      switch call.method {

      // ---------- 시작 ----------
      case "start":
        if #available(iOS 16.1, *) {
          guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("⚠️ Activities disabled on this device")
            result(FlutterError(code:"NOT_ALLOWED", message:"Activities disabled", details:nil)); return
          }
          guard let args = call.arguments as? [String: Any] else {
            print("❌ INVALID_ARGS (missing arguments)")
            result(FlutterError(code:"INVALID_ARGS", message:"Missing arguments", details:nil)); return
          }
          print("📦 [live_activity/start] args =", args)

          // 날짜: epoch(ms) 우선, 문자열 ISO8601 폴백 (대형 정수 안전 처리)
          var startAt: Date?
          if let n = args["liveOnStartAtMs"] {
            print("🧪 liveOnStartAtMs type:", type(of: n))
            if let d = n as? Double {
              startAt = Date(timeIntervalSince1970: d / 1000.0)
            } else if let i64 = n as? Int64 {
              startAt = Date(timeIntervalSince1970: TimeInterval(i64) / 1000.0)
            } else if let i = n as? Int {
              startAt = Date(timeIntervalSince1970: TimeInterval(i) / 1000.0)
            } else if let num = n as? NSNumber {
              startAt = Date(timeIntervalSince1970: num.doubleValue / 1000.0)
            }
          }
          if startAt == nil, let startAtStr = args["liveOnStartAt"] as? String {
            print("🧪 liveOnStartAt (string) =", startAtStr)
            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            startAt = iso.date(from: startAtStr)
            if startAt == nil {
              let isoFallback = ISO8601DateFormatter()
              isoFallback.formatOptions = [.withInternetDateTime]
              startAt = isoFallback.date(from: startAtStr)
            }
          }

          // 다른 필드 안전 파싱
          let todayRide = (args["todayRideCount"] as? Int)
            ?? (args["todayRideCount"] as? NSNumber)?.intValue
          let sessionRide = (args["sessionRideCount"] as? Int)
            ?? (args["sessionRideCount"] as? NSNumber)?.intValue
          let lastSlope = args["lastSlopeName"] as? String

          print("🧪 todayRide:", todayRide as Any,
                "| sessionRide:", sessionRide as Any,
                "| lastSlope:", lastSlope as Any,
                "| startAt:", startAt as Any)

          guard let _today = todayRide,
                let _session = sessionRide,
                let _last = lastSlope,
                let _startAt = startAt else {
            print("❌ INVALID_ARGS (typed fields/date missing)")
            result(FlutterError(code:"INVALID_ARGS", message:"Bad args", details:nil)); return
          }

          let attributes = LiveOnActivityAttributes(liveOnStartAt: _startAt)
          let initial = LiveOnActivityAttributes.ContentState(
            todayRideCount: _today,
            sessionRideCount: _session,
            lastSlopeName: _last
          )

          do {
            let activity = try Activity.request(attributes: attributes, contentState: initial)
            self.liveActivities[activity.id] = activity
            print("✅ Live Activity started:", activity.id)
            result(activity.id)
          } catch {
            print("❌ START_FAILED:", error.localizedDescription)
            result(FlutterError(code:"START_FAILED", message:error.localizedDescription, details:nil))
          }
        } else {
          print("⚠️ iOS < 16.1")
          result(FlutterError(code:"UNSUPPORTED_IOS", message:"Requires iOS 16.1+", details:nil))
        }

      // ---------- 업데이트 ----------
      case "update":
        if #available(iOS 16.1, *) {
          guard
            let args = call.arguments as? [String: Any],
            let id = args["activityId"] as? String,
            let todayRide = (args["todayRideCount"] as? Int) ?? (args["todayRideCount"] as? NSNumber)?.intValue,
            let sessionRide = (args["sessionRideCount"] as? Int) ?? (args["sessionRideCount"] as? NSNumber)?.intValue,
            let lastSlope = args["lastSlopeName"] as? String,
            let activity = self.liveActivities[id] as? Activity<LiveOnActivityAttributes>
          else {
            print("❌ update NOT_FOUND/bad args:", String(describing: call.arguments))
            result(FlutterError(code:"NOT_FOUND", message:"Activity not found", details:nil)); return
          }

          let state = LiveOnActivityAttributes.ContentState(
            todayRideCount: todayRide,
            sessionRideCount: sessionRide,
            lastSlopeName: lastSlope
          )
          Task { await activity.update(using: state) }
          print("🔄 Live Activity updated:", id)
          result(nil)
        } else {
          result(FlutterError(code:"UNSUPPORTED_IOS", message:"Requires iOS 16.1+", details:nil))
        }

      // ---------- 종료 ----------
      case "end":
        if #available(iOS 16.1, *) {
          guard
            let args = call.arguments as? [String: Any],
            let id = args["activityId"] as? String,
            let activity = self.liveActivities[id] as? Activity<LiveOnActivityAttributes>
          else {
            print("❌ end NOT_FOUND/bad args:", String(describing: call.arguments))
            result(FlutterError(code:"NOT_FOUND", message:"Activity not found", details:nil)); return
          }

          Task { await activity.end(dismissalPolicy: .immediate) }
          self.liveActivities.removeValue(forKey: id)
          print("🛑 Live Activity ended:", id)
          result(nil)
        } else {
          result(FlutterError(code:"UNSUPPORTED_IOS", message:"Requires iOS 16.1+", details:nil))
        }

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // ✅ 플러그인 등록
    GeneratedPluginRegistrant.register(with: self)
    print("✅ GeneratedPluginRegistrant registered")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
