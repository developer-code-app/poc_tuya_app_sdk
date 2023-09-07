import UIKit
import Flutter
import ThingSmartBaseKit
import ThingSmartDeviceKit
import ThingSmartActivatorKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, ThingSmartActivatorDelegate  {
    let tuyaActivator = ThingSmartActivator()
    var pairingMethodCall: FlutterMethodCall?
    var pairingResult: FlutterResult?

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
      case "loginWithUID":
        self.loginWithUID(call: call, result: result)
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
      case "fetchDevices":
        self.fetchDevices(call: call, result: result)
      case "editDevice":
        self.editDevice(call: call, result: result)
      case "removeDevice":
        self.removeDevice(call: call, result: result)
      case "fetchPairingToken":
        self.fetchPairingToken(call: call, result: result)
      case "startPairingDeviceWithAPMode":
        self.startPairingDeviceWithAPMode(call: call, result: result)
      case "startPairingDeviceWithEZMode":
        self.startPairingDeviceWithEZMode(call: call, result: result)
      case "startPairingDeviceWithZigbeeGateway":
        self.startPairingDeviceWithZigbeeGateway(call: call, result: result)
      case "startPairingDeviceWithSubDevices":
        self.startPairingDeviceWithSubDevices(call: call, result: result)
      case "stopPairingDevice":
        self.stopPairingDevice(call: call, result: result)
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
    
  private func loginWithUID(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard
      let args = call.arguments as? Dictionary<String, Any>,
      let countryCode = args["country_code"] as? String,
      let uid = args["uid"] as? String,
      let password = args["password"] as? String
    else {
      let flutterError = FlutterError(
        code: "ARGUMENTS_ERROR",
        message: "Arguments missing.",
        details: nil
      );

      return result(flutterError)
    }
      
    ThingSmartUser.sharedInstance().loginOrRegister(
      withCountryCode: countryCode,
      uid: uid,
      password: password,
      createHome: true,
      success: { (response) in
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
      }, failure: { (error) in
		    let flutterError = FlutterError(
          code: "LOGIN_ERROR",
          message: error?.localizedDescription,
          details: nil
        );
  
        result(flutterError)
      })
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
        ThingSmartHomeManager().getHomeList(success: { (homes) in
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
        
        ThingSmartHomeManager().addHome(withName: name,
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
    
    private func fetchDevices(call: FlutterMethodCall, result: @escaping FlutterResult) {
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
        
        home?.getDataWithSuccess({ homeModle in
            let devices = home?.deviceList ?? []

            result(
                devices.map { device in
                    return [
                        "device_id": device.devId!,
                        "name": device.name!,
                        "is_zig_bee_wifi": device.deviceType == ThingSmartDeviceModelTypeZigbeeGateway,
                    ];
                }
            );
        }, failure: { error in
            let flutterError = FlutterError(
              code: "HOME_NOT_FOUND",
              message: "Arguments missing.",
              details: nil
            );

            return result(flutterError)
        })
    }
    
    private func editDevice(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard
          let args = call.arguments as? Dictionary<String, Any>,
          let deviceId = args["device_id"] as? String,
          let name = args["name"] as? String
        else {
          let flutterError = FlutterError(
            code: "ARGUMENTS_ERROR",
            message: "Arguments missing.",
            details: nil
          );

          return result(flutterError)
        }
        
        let device = ThingSmartDevice(deviceId: deviceId)
        
        device?.updateName(name, success: {
            result(name);
        }, failure: { (error) in
            let flutterError = FlutterError(
              code: "EDIT_DEVICE_ERROR",
              message: error?.localizedDescription,
              details: nil
            );
        
            result(flutterError)
        })
    }
    
    private func removeDevice(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard
          let args = call.arguments as? Dictionary<String, Any>,
          let deviceId = args["device_id"] as? String
        else {
          let flutterError = FlutterError(
            code: "ARGUMENTS_ERROR",
            message: "Arguments missing.",
            details: nil
          );

          return result(flutterError)
        }
        
        let device = ThingSmartDevice(deviceId: deviceId)
        
        device?.remove({
            result("SUCCESS")
        }, failure: { (error) in
            let flutterError = FlutterError(
              code: "REMOVE_DEVICE_ERROR",
              message: error?.localizedDescription,
              details: nil
            );
        
            result(flutterError)
        })
    }
    
    private func fetchPairingToken(call: FlutterMethodCall, result: @escaping FlutterResult) {
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
        
        tuyaActivator.getTokenWithHomeId(homeId, success: { token in
            result(token)
        }, failure: { error in
            let flutterError = FlutterError(
              code: "GET_TOKEN_ERROR",
              message: error?.localizedDescription,
              details: nil
            );
        
            result(flutterError)
        })
    }
    
    private func startPairingDeviceWithAPMode(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard
          let args = call.arguments as? Dictionary<String, Any>,
          let ssid = args["ssid"] as? String,
            let password = args["password"] as? String,
            let token = args["token"] as? String,
            let timeout = args["time_out"] as? Int?
        else {
          let flutterError = FlutterError(
            code: "ARGUMENTS_ERROR",
            message: "Arguments missing.",
            details: nil
          );

          return result(flutterError)
        }
     
        pairingMethodCall = call
        pairingResult = result
        tuyaActivator.delegate = self
        tuyaActivator.startConfigWiFi(
            .AP,
            ssid: ssid,
            password: password,
            token: token,
            timeout: TimeInterval(timeout ?? 200)
        )
    }
    
    private func startPairingDeviceWithEZMode(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard
          let args = call.arguments as? Dictionary<String, Any>,
          let ssid = args["ssid"] as? String,
            let password = args["password"] as? String,
            let token = args["token"] as? String,
            let timeout = args["time_out"] as? Int?
        else {
          let flutterError = FlutterError(
            code: "ARGUMENTS_ERROR",
            message: "Arguments missing.",
            details: nil
          );

          return result(flutterError)
        }
     
        pairingMethodCall = call
        pairingResult = result
        tuyaActivator.delegate = self
        tuyaActivator.startConfigWiFi(
            .EZ,
            ssid: ssid,
            password: password,
            token: token,
            timeout: TimeInterval(timeout ?? 200)
        )
    }
    
    private func startPairingDeviceWithZigbeeGateway(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard
            let arguments = pairingMethodCall?.arguments as? Dictionary<String, Any>,
            let token = arguments["token"] as? String,
            let timeout = arguments["time_out"] as? Int?
        else {
            pairingResult?(
                FlutterError(
                  code: "ARGUMENTS_ERROR",
                  message: "Arguments missing.",
                  details: nil
                )
            )

            return
        }
        
        pairingMethodCall = call
        pairingResult = result
        tuyaActivator.delegate = self
        tuyaActivator.startConfigWiFi(
            withToken: token,
            timeout: TimeInterval(timeout ?? 200)
        )
    }

    private func startPairingDeviceWithSubDevices(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard
            let arguments = pairingMethodCall?.arguments as? Dictionary<String, Any>,
            let gatewayId = arguments["gateway_id"] as? String,
            let timeout = arguments["time_out"] as? Int?
        else {
            pairingResult?(
                FlutterError(
                  code: "ARGUMENTS_ERROR",
                  message: "Arguments missing.",
                  details: nil
                )
            )

            return
        }
        
        pairingMethodCall = call
        pairingResult = result
        tuyaActivator.delegate = self
        tuyaActivator.activeSubDevice(
            withGwId: gatewayId,
            timeout: TimeInterval(timeout ?? 200)
        )
    }
    
    private func stopPairingDevice(call: FlutterMethodCall, result: @escaping FlutterResult) {
        pairingMethodCall = nil
        pairingResult = nil
        tuyaActivator.delegate = nil
        tuyaActivator.stopConfigWiFi()
    }
    
    func activator(_ activator: ThingSmartActivator!, didReceiveDevice deviceModel: ThingSmartDeviceModel!, error: Error!) {
        if deviceModel != nil && error == nil {
            pairingResult?("SUCCESS")
        }
        
        if let error = error {
            let flutterError = FlutterError(
              code: "PAIRING_ERROR",
              message: error.localizedDescription,
              details: nil
            );
        
            pairingResult?(flutterError)
        }
    }
}
