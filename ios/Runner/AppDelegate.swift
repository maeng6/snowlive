import UIKit
import Flutter
import GoogleMaps
import ActivityKit
import UserNotifications
import WidgetKit

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

    // ✅ 플러그인 등록
    GeneratedPluginRegistrant.register(with: self)

    // ✅ 알림 델리게이트
    UNUserNotificationCenter.current().delegate = self

    // ✅ 플러터 루트 VC
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
    let liveActivityChannel = FlutterMethodChannel(
      name: "live_activity",
      binaryMessenger: controller.binaryMessenger
    )

    liveActivityChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }

      switch call.method {

      // ---------- 시작 ----------
      case "start":
        if #available(iOS 16.1, *) {
          print("🟡 [LA] start() called from Flutter")

          guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("⚠️ [LA] Activities disabled by system/user")
            result(FlutterError(code:"NOT_ALLOWED", message:"Activities disabled", details:nil))
            return
          }

          self.ensureNotificationForLiveActivity { ok in
            guard ok else {
              result(FlutterError(code:"NOTIFICATIONS_DISABLED", message:"Notifications/LockScreen disabled", details:nil))
              return
            }

            guard let args = call.arguments as? [String: Any] else {
              print("❌ [LA] INVALID_ARGS (missing)")
              result(FlutterError(code:"INVALID_ARGS", message:"Missing arguments", details:nil)); return
            }

            var startAt: Date?
            if let n = args["liveOnStartAtMs"] {
              if let d = n as? Double { startAt = Date(timeIntervalSince1970: d / 1000.0) }
              else if let i64 = n as? Int64 { startAt = Date(timeIntervalSince1970: TimeInterval(i64) / 1000.0) }
              else if let i = n as? Int { startAt = Date(timeIntervalSince1970: TimeInterval(i) / 1000.0) }
              else if let num = n as? NSNumber { startAt = Date(timeIntervalSince1970: num.doubleValue / 1000.0) }
            }

            let todayRide = (args["todayRideCount"] as? Int) ?? (args["todayRideCount"] as? NSNumber)?.intValue
            let sessionRide = (args["sessionRideCount"] as? Int) ?? (args["sessionRideCount"] as? NSNumber)?.intValue
            let lastSlope = args["lastSlopeName"] as? String
            let resortName = args["resortName"] as? String ?? ""
            let liveFriendCount = (args["liveFriendCount"] as? Int) ?? (args["liveFriendCount"] as? NSNumber)?.intValue ?? 0

            print("📍 [LA] resortName from Flutter: \(resortName)")

            // lastRideAt 파싱 (optional)
            var lastRideAt: Date? = nil
            if let n = args["lastRideAtMs"] {
              if let d = n as? Double { lastRideAt = Date(timeIntervalSince1970: d / 1000.0) }
              else if let i64 = n as? Int64 { lastRideAt = Date(timeIntervalSince1970: TimeInterval(i64) / 1000.0) }
              else if let i = n as? Int { lastRideAt = Date(timeIntervalSince1970: TimeInterval(i) / 1000.0) }
              else if let num = n as? NSNumber { lastRideAt = Date(timeIntervalSince1970: num.doubleValue / 1000.0) }
            }

            guard let _startAt = startAt,
                  let _today = todayRide,
                  let _session = sessionRide,
                  let _last = lastSlope else {
              print("❌ [LA] INVALID_ARGS (typed fields/date missing)")
              result(FlutterError(code:"INVALID_ARGS", message:"Bad args", details:nil)); return
            }

            let attributes = LiveOnActivityAttributes(liveOnStartAt: _startAt, resortName: resortName)
            let initial = LiveOnActivityAttributes.ContentState(
              todayRideCount: _today,
              sessionRideCount: _session,
              lastSlopeName: _last,
              lastRideAt: lastRideAt,
              liveFriendCount: liveFriendCount
            )

            do {
              let activity = try Activity.request(attributes: attributes, contentState: initial)
              self.liveActivities[activity.id] = activity
              print("✅ [LA] Live Activity started id = \(activity.id)")
              result(activity.id)
            } catch {
              print("❌ [LA] START_FAILED:", error.localizedDescription)
              result(FlutterError(code:"START_FAILED", message:error.localizedDescription, details:nil))
            }
          }

        } else {
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
            print("❌ [LA] update NOT_FOUND/bad args:", String(describing: call.arguments))
            result(FlutterError(code:"NOT_FOUND", message:"Activity not found or bad args", details:nil)); return
          }

          // lastRideAt 파싱 (optional)
          var lastRideAt: Date? = nil
          if let n = args["lastRideAtMs"] {
            if let d = n as? Double { lastRideAt = Date(timeIntervalSince1970: d / 1000.0) }
            else if let i64 = n as? Int64 { lastRideAt = Date(timeIntervalSince1970: TimeInterval(i64) / 1000.0) }
            else if let i = n as? Int { lastRideAt = Date(timeIntervalSince1970: TimeInterval(i) / 1000.0) }
            else if let num = n as? NSNumber { lastRideAt = Date(timeIntervalSince1970: num.doubleValue / 1000.0) }
          }

          // liveFriendCount 파싱
          let liveFriendCount = (args["liveFriendCount"] as? Int) ?? (args["liveFriendCount"] as? NSNumber)?.intValue ?? 0

          let state = LiveOnActivityAttributes.ContentState(
            todayRideCount: todayRide,
            sessionRideCount: sessionRide,
            lastSlopeName: lastSlope,
            lastRideAt: lastRideAt,
            liveFriendCount: liveFriendCount
          )
          Task { await activity.update(using: state) }
          print("🔄 [LA] updated id=\(id), lastSlope=\(lastSlope), liveFriends=\(liveFriendCount)")
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
            print("❌ [LA] end NOT_FOUND/bad args:", String(describing: call.arguments))
            result(FlutterError(code:"NOT_FOUND", message:"Activity not found or bad args", details:nil)); return
          }

          let reason = (args["reason"] as? String) ?? "unspecified"
          print("🛑 [LA] end() called (reason=\(reason)) id=\(id)")

          Task { await activity.end(dismissalPolicy: .immediate) }
          self.liveActivities.removeValue(forKey: id)
          print("✅ [LA] ended id=\(id)")
          result(nil)
        } else {
          result(FlutterError(code:"UNSUPPORTED_IOS", message:"Requires iOS 16.1+", details:nil))
        }

      default:
        result(FlutterMethodNotImplemented)
      }
    }
    print("🔌 live_activity channel registered")

    // ✅ 부팅 시 상태 로그
    debugNotificationSettings()
    if #available(iOS 16.1, *) { debugLiveActivitiesStatus() }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - Debug / Helper methods (⚠️ 반드시 클래스 내부에 위치)

  /// 알림/잠금화면 허용 상태 로깅
  private func debugNotificationSettings() {
    UNUserNotificationCenter.current().getNotificationSettings { s in
      print("""
      🔔 UNNotificationSettings
        authorizationStatus = \(s.authorizationStatus.rawValue)  // 0:notDetermined 1:denied 2:authorized 3:provisional 4:ephemeral 5:scheduledSummary
        alertSetting        = \(s.alertSetting.rawValue)         // 0:notSupported 1:disabled 2:enabled
        lockScreenSetting   = \(s.lockScreenSetting.rawValue)    // 0:notSupported 1:disabled 2:enabled
        notificationCenter  = \(s.notificationCenterSetting.rawValue)
        badgeSetting        = \(s.badgeSetting.rawValue)
        soundSetting        = \(s.soundSetting.rawValue)
        timeSensitive       = \(s.timeSensitiveSetting.rawValue)
      """)
    }
  }

  /// Live Activities 시스템 사용 가능 여부 로깅 (iOS 16.1+)
  @available(iOS 16.1, *)
  private func debugLiveActivitiesStatus() {
    let info = ActivityAuthorizationInfo()
    print("📟 LiveActivities areActivitiesEnabled = \(info.areActivitiesEnabled)")
  }

  /// Live Activity 표시를 위한 알림/잠금화면 권한 보장
  private func ensureNotificationForLiveActivity(completion: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current().getNotificationSettings { s in
      // 미결정이면 한 번 요청
      if s.authorizationStatus == .notDetermined {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { ok, err in
          print("🔔 requestAuthorization ok=\(ok) err=\(String(describing: err))")
          DispatchQueue.main.async { completion(ok) }
        }
        return
      }

      // 거절/비활성 → 설정앱 유도 후 false
      guard s.authorizationStatus == .authorized,
            s.lockScreenSetting == .enabled,
            s.alertSetting == .enabled else {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
          if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
          }
        }
        DispatchQueue.main.async { completion(false) }
        return
      }

      // 통과
      DispatchQueue.main.async { completion(true) }
    }
  }
}
