import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "com.code-app/poc-smart-lift-sdk-flutter",
      binaryMessenger: controller.binaryMessenger
    )
    
    channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      switch call.method {
      case "loginWithEmail":
        self.loginWithEmail(call: call, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func loginWithEmail(call: FlutterMethodCall, result: @escaping FlutterResult) {
      guard
        let args = call.arguments as? Dictionary<String, Any>,
        let countryCode = args["country_code"] as? String,
        let email = args["email"] as? String,
        let password = args["password"] as? String
      else {
        let flutterError = FlutterError(
          code: "ARGUMENTS_ERROR",
          message: "Arguments missing.",
          details: nil
        );
          
        return result(flutterError)
      }
      
      TuyaSmartUser.sharedInstance().login(
        byEmail: countryCode,
        email: email,
        password: password
      ) {
        result("login success");
      } failure: { error in
        let flutterError = FlutterError(
          code: "TUYA_LOGIN_ERROR",
          message: error?.localizedDescription,
          details: nil
        );
          
        result(flutterError)
      }
  }
}
