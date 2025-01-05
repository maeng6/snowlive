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

    // 배터리 절약 모드 감지 설정
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "detect_battery_saver", binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "isBatterySaverOn" {
        // 배터리 절약 모드 확인
        let isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
        result(isLowPowerMode)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
