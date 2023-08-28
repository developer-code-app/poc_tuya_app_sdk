import UIKit
import Flutter
import ThingSmartBaseKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    setupTuyaSmartLife()
    setupMethodCall()
      
    GeneratedPluginRegistrant.register(with: self)
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func setupTuyaSmartLife() {
    ThingSmartSDK.sharedInstance().start(withAppKey: AppKey.appKey, secretKey: AppKey.secretKey)

    #if DEBUG
      TuyaSmartSDK.sharedInstance().debugMode = true
    #endif
  }
  
  private func setupMethodCall() {
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
      case "updateNickname":
        self.updateNickname(call: call, result: result)
      case "logout":
        self.logout(call: call, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    })
  }
    
    private func updateNickname(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard
          let args = call.arguments as? Dictionary<String, Any>,
          let nickname = args["nickname"] as? String
        else {
          let flutterError = FlutterError(
            code: "ARGUMENTS_ERROR",
            message: "Arguments missing.",
            details: nil
          );

          return result(flutterError)
        }
        
        ThingSmartUser.sharedInstance().updateNickname(nickname, success: {
            result("SUCCESS");
        }, failure: { (error) in
            let flutterError = FlutterError(
              code: "UPDATE_NICKNAME_ERROR",
              message: error?.localizedDescription,
              details: nil
            );
        
            result(flutterError)
        })
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
      
    ThingSmartUser.sharedInstance().login(
      byEmail: countryCode,
      email: email,
      password: password
    ) {
        let user = ThingSmartUser.sharedInstance()
        
        result(
          [
            "user_id": user.uid,
            "session_id": user.sid,
            "user_name": user.userName,
            "email": user.email,
            "nickname": user.nickname
          ]
        );
    } failure: { error in
      let flutterError = FlutterError(
        code: "LOGIN_ERROR",
        message: error?.localizedDescription,
        details: nil
      );
  
      result(flutterError)
    }
  }
    
    private func logout(call: FlutterMethodCall, result: @escaping FlutterResult) {
        ThingSmartUser.sharedInstance().loginOut({
            result("SUCCESS")
        }, failure: { (error) in
            let flutterError = FlutterError(
              code: "LOGOUT_ERROR",
              message: error?.localizedDescription,
              details: nil
            );
        
            result(flutterError)
        })
    }
}
