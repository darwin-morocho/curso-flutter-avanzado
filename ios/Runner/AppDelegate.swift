import UIKit
import Flutter
import CoreLocation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, GeolocationDelegate {
    
    func onLocationUpdate(coords: CLLocationCoordinate2D) {
        channel?.invokeMethod("onLocation", arguments: ["lat":coords.latitude,"lng":coords.longitude])
    }
    
    
    let geolocation = Geolocation()
    var channel:FlutterMethodChannel?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        geolocation.delegate = self
        
        let controller  = window.rootViewController as! FlutterBinaryMessenger
        channel = FlutterMethodChannel(name: "ec.dina/geolocation", binaryMessenger: controller)
        
        channel?.setMethodCallHandler({
            (call:FlutterMethodCall,result:@escaping FlutterResult)->Void in
            
            
            switch call.method{
            case "permission":
                self.geolocation.checkPermission(result: result)
            case "startTracking":
                self.geolocation.startTracking()
                result(nil)
                
                case "stopTracking":
                self.geolocation.stopTracking()
                result(nil)
                
                
                
            default: result(FlutterMethodNotImplemented)
                
            }
            
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
