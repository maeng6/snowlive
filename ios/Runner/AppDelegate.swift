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

    // ⚠️ iOS 26 UIScene 생명주기에선 이 시점에 window가 아직 없다(Scene 연결 시 생성).
    // 그래서 FlutterViewController가 필요한 채널 등록은 SceneDelegate가 Scene 연결 후
    // registerFlutterChannels(with:)를 호출해 처리한다.

    // ✅ 부팅 시 상태 로그
    debugNotificationSettings()
    if #available(iOS 16.1, *) { debugLiveActivitiesStatus() }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - Flutter 네이티브 채널 등록
  /// 윈도우/루트VC가 준비된 뒤(Scene 연결 시점) SceneDelegate가 호출한다.
  func registerFlutterChannels(with controller: FlutterViewController) {
    print("✅ registerFlutterChannels, controller ready")

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

      // ---------- 모두 종료 ----------
      case "endAll":
        if #available(iOS 16.1, *) {
          print("🧹 [LA] endAll() called from Flutter")
          Task {
            for activity in Activity<LiveOnActivityAttributes>.activities {
              await activity.end(dismissalPolicy: .immediate)
              print("🛑 [LA] ended activity id=\(activity.id)")
            }
            self.liveActivities.removeAll()
            print("✅ [LA] endAll completed")
          }
          result(nil)
        } else {
          result(nil)  // iOS 16.1 미만은 무시
        }

      default:
        result(FlutterMethodNotImplemented)
      }
    }
    print("🔌 live_activity channel registered")
  }

  // MARK: - Deep Link (URL Scheme) 처리
  // 레거시(앱 생명주기) 경로 — UIScene에서는 SceneDelegate.scene(_:openURLContexts:)가 처리한다.
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      handleDeepLink(url, controller: controller)
    }
    return super.application(app, open: url, options: options)
  }

  // MARK: - 딥링크 전달 (AppDelegate/SceneDelegate 공통)
  func handleDeepLink(_ url: URL, controller: FlutterViewController) {
    print("📱 openURL → Flutter: \(url)")
    let channel = FlutterMethodChannel(name: "deep_link_native", binaryMessenger: controller.binaryMessenger)
    channel.invokeMethod("onDeepLink", arguments: url.absoluteString)
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

// MARK: - UIScene 생명주기 (iOS 26 요구사항)

/// iOS 26 UIScene 생명주기 채택용 Scene 델리게이트.
///
/// Flutter 기본 [FlutterSceneDelegate]를 상속해 윈도우/루트VC 생성·플러그인 생명주기
/// 연동은 그대로 두고, **윈도우가 준비된 뒤**에 AppDelegate의 네이티브 채널 등록과
/// 딥링크 처리를 호출한다(채널·Live Activity 상태는 AppDelegate가 계속 소유).
///
/// Info.plist의 UIApplicationSceneManifest → UISceneDelegateClassName = "SceneDelegate"
/// 가 이 클래스를 가리킨다(@objc 이름 고정). 별도 파일 대신 이 파일에 둔 이유는
/// Xcode 프로젝트(pbxproj)에 새 파일을 등록하지 않아도 되게 하기 위함.
@objc(SceneDelegate)
class SceneDelegate: FlutterSceneDelegate {

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    // 먼저 Flutter가 윈도우 + FlutterViewController를 구성하게 한다.
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    guard
      let controller = window?.rootViewController as? FlutterViewController,
      let appDelegate = UIApplication.shared.delegate as? AppDelegate
    else {
      print("❌ SceneDelegate: FlutterViewController/AppDelegate 준비 실패")
      return
    }

    // 윈도우가 생긴 지금 네이티브 채널(배터리/라이브액티비티)을 등록한다.
    appDelegate.registerFlutterChannels(with: controller)

    // 콜드 스타트 딥링크(앱이 URL로 처음 실행된 경우).
    if let url = connectionOptions.urlContexts.first?.url {
      appDelegate.handleDeepLink(url, controller: controller)
    }
  }

  // iOS가 백그라운드 전환 시 요구하는 "상태복원 NSUserActivity"를 만들지 않는다.
  // FlutterSceneDelegate 기본 구현이 타입 없는 NSUserActivity를 돌려주는데, Info.plist에
  // NSUserActivityTypes가 없어 iOS 26에서 백그라운드 갈 때마다 크래시가 난다
  // ('Caller did not provide an activityType…'). 이 앱은 iOS 상태복원을 쓰지 않으므로
  // nil을 돌려 비활성화한다(홈버튼·앱전환·외부URL 열기 등 모든 백그라운드 전환 보호).
  override func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
    return nil
  }

  // 앱 실행 중 URL 스킴으로 열릴 때(UIScene 경로).
  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard
      let url = URLContexts.first?.url,
      let controller = window?.rootViewController as? FlutterViewController,
      let appDelegate = UIApplication.shared.delegate as? AppDelegate
    else { return }
    appDelegate.handleDeepLink(url, controller: controller)
  }
}
