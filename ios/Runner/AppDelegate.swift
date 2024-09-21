import UIKit
import Flutter
import GoogleMaps
import FBSDKCoreKit  // Facebook SDK 추가

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Google Maps API Key 제공
    GMSServices.provideAPIKey("AIzaSyDpVj2pG6ui0KeBrYzyV-IEUQWQUGMAeCE")

    // Facebook SDK 초기화
    ApplicationDelegate.shared.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )

    // Flutter Plugins 등록
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 페이스북 로그인 및 기타 URL 스킴을 처리하기 위한 메서드
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // Facebook SDK가 URL 처리
    let handled = ApplicationDelegate.shared.application(
      app,
      open: url,
      sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
      annotation: options[UIApplication.OpenURLOptionsKey.annotation]
    )

    // Flutter 및 기타 URL 스킴 처리
    if handled {
      return true
    } else {
      return super.application(app, open: url, options: options)
    }
  }
}
