//
//  OneShotLocationManager.swift
//  testTaskGLPGS
//
//  Created by Konstantin Bogunov on 27.07.15.
//  Copyright (c) 2015 Konstantin Bogunov. All rights reserved.
//
import UIKit
import CoreLocation

//possible errors
enum OneShotLocationManagerErrors: Int {
    case AuthorizationDenied
    case AuthorizationNotDetermined
    case InvalidLocation
}

class OneShotLocationManager: NSObject, CLLocationManagerDelegate {
    
    //location manager
    private var locationManager: CLLocationManager?
    
    //locations array
    var locationsList: [CLLocationCoordinate2D] = []
    
    //destroy the manager
    deinit {
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    typealias LocationClosure = ((location: CLLocation?, error: NSError?)->())
    private var didComplete: LocationClosure?

    //location manager returned, call didcomplete closure
    private func _didComplete(location: CLLocation?, error: NSError?) {
        locationManager?.stopUpdatingLocation()
        didComplete?(location: location, error: error)
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    //location authorization status changed
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch status {
        case .AuthorizedWhenInUse:
            self.locationManager!.startUpdatingLocation()
        case .Denied:
            _didComplete(nil, error: NSError(domain: self.classForCoder.description(),
                code: OneShotLocationManagerErrors.AuthorizationDenied.rawValue,
                userInfo: nil))
        default:
            break
        }
    }
    
    internal func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        _didComplete(nil, error: error)
    }
    
    internal func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
         println(newLocation)
    }
    
    internal func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
          
        if let location = locations[0] as? CLLocation {
            _didComplete(location, error: nil)
           
            var locationArray = locations as NSArray
            var locationObj = locationArray.lastObject as! CLLocation
            var coord = locationObj.coordinate
            
            println(coord.latitude)
            println(coord.longitude)
            
            //add new location
//            println(location.coordinate)
//            self.locationsList.append(location.coordinate)
            
        } else {
            _didComplete(nil, error: NSError(domain: self.classForCoder.description(),
                code: OneShotLocationManagerErrors.InvalidLocation.rawValue,
                userInfo: nil))
        }
    }
    
    //ask for location permissions, fetch 1 location, and return
    func fetchWithCompletion(completion: LocationClosure) {
        //store the completion closure
        didComplete = completion

        locationManager = CLLocationManager()
        locationManager!.delegate = self

        //check for description key and ask permissions
        if (NSBundle.mainBundle().objectForInfoDictionaryKey("NSLocationWhenInUseUsageDescription") != nil) {
            locationManager!.requestWhenInUseAuthorization()
        } else if (NSBundle.mainBundle().objectForInfoDictionaryKey("NSLocationAlwaysUsageDescription") != nil) {
            locationManager!.requestAlwaysAuthorization()
        } else {
            fatalError("To use location in iOS8 you need to define either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription in the app bundle's Info.plist file")
        }
        
    }
}