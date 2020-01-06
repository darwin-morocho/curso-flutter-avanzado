//
//  Geolocation.swift
//  Runner
//
//  Created by Darwin Morocho on 10/21/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import CoreLocation
import Flutter


protocol GeolocationDelegate {
    func onLocationUpdate(coords:CLLocationCoordinate2D)
}

class Geolocation: NSObject,CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var result:FlutterResult?
    var delegate: GeolocationDelegate?
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let coords:CLLocationCoordinate2D = location.coordinate
            delegate?.onLocationUpdate(coords: coords)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let clientResponse =  checkPermissionStatus(status: status)
        sendResult(response: clientResponse)
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    
    private func setResult(result:@escaping FlutterResult)-> Bool{
        
        if(self.result != nil){
            self.result?(FlutterError(code: "PENDING_RESULT_ERROR", message: "error you have a pending task", details: ""))
            self.result = nil
            return false
        }
        self.result = result
        return true
    }
    
    
    private func sendResult(response:String)  {
        self.result?(response)
        self.result = nil
    }
    
    
    
    private func requestPermission()  {
        locationManager.requestWhenInUseAuthorization()
    }
    
    
    
    func checkPermission(result:@escaping FlutterResult){
        let isTrue =  setResult(result: result)
        if(isTrue){
            let status =  checkPermissionStatus(status:CLLocationManager.authorizationStatus())
            if(status=="ASK"){
                requestPermission()
            }else{
                sendResult(response: status)
            }
        }
    }
    
    func startTracking()  {
        locationManager.startUpdatingLocation()
    }
    
    func stopTracking()  {
        locationManager.stopUpdatingLocation()
    }
    
    
    private func checkPermissionStatus(status:CLAuthorizationStatus) -> String {
        
        switch status {
        case .authorizedWhenInUse:
            return "GRANTED"
        case .denied:
            return "DENIED"
        case .restricted:
            return "RESTRICTED"
        case .notDetermined:
            return "ASK"
        default:
            return "UNKNOWN"
        }
        
    }
    
    
}
