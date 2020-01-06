import Flutter
import UIKit
import CoreLocation

public class SwiftFlutterGelocationTrackingPlugin: NSObject, FlutterPlugin, GeolocationDelegate {
    
    
    
    func onLocationUpdate(coords: CLLocationCoordinate2D) {
        print("onLocationUpdate")
        channel?.invokeMethod("onLocation", arguments: ["lat":coords.latitude,"lng":coords.longitude])
    }
    
    let geolocation = Geolocation()
     var channel:FlutterMethodChannel?
    
    
    public init(channel:FlutterMethodChannel) {
        super.init()
        self.channel = channel
        self.geolocation.delegate = self
    }
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ec.dina/geolocation", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterGelocationTrackingPlugin(channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    
    switch call.method{
             case "permission":
                 self.geolocation.checkPermission(result: result)
             case "startTracking":
                print("startTracking")
                 self.geolocation.startTracking()
                 result(nil)
                 
                 case "stopTracking":
                 self.geolocation.stopTracking()
                 result(nil)
                 
                 
                 
             default: result(FlutterMethodNotImplemented)
                 
             }
    
    
  }
}
