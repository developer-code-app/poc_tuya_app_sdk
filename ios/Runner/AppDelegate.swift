import UIKit
import Flutter
import ThingSmartBaseKit
import ThingSmartDeviceKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    let homeManager = ThingSmartHomeManager()
    
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
      case "fetchHomes":
        self.fetchHomes(call: call, result: result)
      case "addHome":
        self.addHome(call: call, result: result)
      case "editHome":
        self.editHome(call: call, result: result)
      case "removeHome":
        self.removeHome(call: call, result: result)
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
    
    private func fetchHomes(call: FlutterMethodCall, result: @escaping FlutterResult) {
        homeManager.getHomeList(success: { (homes) in
            if let homes = homes {
                let _homes = homes.map { home in
                    [
                        "home_id": String(home.homeId),
                        "name": home.name!,
                    ]
                }

                result(_homes)
            } else {
                result([])
            }
        }) { (error) in
            let flutterError = FlutterError(
              code: "FETCH_HOMES_ERROR",
              message: error?.localizedDescription,
              details: nil
            );
        
            result(flutterError)
        }
    }
    
    private func addHome(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard
          let args = call.arguments as? Dictionary<String, Any>,
          let name = args["name"] as? String,
          let rooms = args["rooms"] as? Array<String>,
          let location = args["location"] as? String,
          let latitude = args["latitude"] as? Double,
          let longitude = args["longitude"] as? Double
        else {
          let flutterError = FlutterError(
            code: "ARGUMENTS_ERROR",
            message: "Arguments missing.",
            details: nil
          );

          return result(flutterError)
        }
        
        homeManager.addHome(withName: name,
                             geoName: location,
                               rooms: rooms,
                            latitude: latitude,
                           longitude: longitude,
                             success: { (homeId) in
            result(String(homeId))
        }) { (error) in
            let flutterError = FlutterError(
              code: "ADD_HOMES_ERROR",
              message: error?.localizedDescription,
              details: nil
            );
        
            result(flutterError)
        }
    }
    
    private func editHome(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard
          let args = call.arguments as? Dictionary<String, Any>,
          let homeIdString = args["home_id"] as? String,
          let homeId = Int64(homeIdString),
          let name = args["name"] as? String,
          let location = args["location"] as? String,
          let latitude = args["latitude"] as? Double,
          let longitude = args["longitude"] as? Double
        else {
          let flutterError = FlutterError(
            code: "ARGUMENTS_ERROR",
            message: "Arguments missing.",
            details: nil
          );

          return result(flutterError)
        }
        
        let home = ThingSmartHome(homeId: homeId);
        
        home?.updateInfo(
            withName: name,
            geoName: location,
            latitude: latitude,
            longitude: longitude,
            success: { result("SUCCESS") },
            failure: { (error) in
                let flutterError = FlutterError(
                  code: "EDIT_HOMES_ERROR",
                  message: error?.localizedDescription,
                  details: nil
                );
            
                result(flutterError)
            })
    }
    
    private func removeHome(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard
          let args = call.arguments as? Dictionary<String, Any>,
          let homeIdString = args["home_id"] as? String,
          let homeId = Int64(homeIdString)
        else {
          let flutterError = FlutterError(
            code: "ARGUMENTS_ERROR",
            message: "Arguments missing.",
            details: nil
          );

          return result(flutterError)
        }
        
        let home = ThingSmartHome(homeId: homeId);
        
        home?.dismiss(success: {
            result("SUCCESS")
        }, failure: { (error) in
            let flutterError = FlutterError(
              code: "REMOVE_HOMES_ERROR",
              message: error?.localizedDescription,
              details: nil
            );
        
            result(flutterError)
        })
    }
}
