import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Google Maps API Key 제공
    GMSServices.provideAPIKey("AIzaSyDpVj2pG6ui0KeBrYzyV-IEUQWQUGMAeCE")

    // Flutter Plugins 등록
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 페이스북 로그인 및 기타 URL 스킴을 처리하기 위한 메서드 삭제
}
