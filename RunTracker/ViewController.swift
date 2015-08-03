//
//  ViewController.swift
//  RunTracker
//
//  Created by Konstantin Bogunov on 28.07.15.
//  Copyright (c) 2015 Konstantin Bogunov. All rights reserved.
//

import UIKit
import MapKit

class PointAnnotation: MKPointAnnotation {
    override init(){
    super.init()
    }
}

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView?
    @IBOutlet weak var speedLable: UILabel?
    
    var manager: OneShotLocationManager?
    var saveAnnotation: MKPointAnnotation?
    var currentSpeed:CLLocationSpeed?
    var locationsList: [CLLocationCoordinate2D] = []
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getLocation()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView!.userTrackingMode = .Follow
        
        self.refreshSpeed()
        
        self.setTimer()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Get location
    
    func getLocation(){
        
        manager = OneShotLocationManager()
        manager!.fetchWithCompletion {location, error in
            
            // fetch location or an error
            if let loc = location {
                println(location)
                
                //remember the location
                let annotation = MKPointAnnotation()
                annotation.coordinate = location!.coordinate
                self.currentSpeed = location?.speed
                self.saveAnnotation = annotation
                
            } else if let err = error {
                println(err.localizedDescription)
            }
            
        }
        
    }
    
    // MARK: - Map Overlay
    
    var returnOverlay: MKPolyline?
    
    func clearOverlay() {
        if let overlay = returnOverlay {
            mapView!.removeOverlay(overlay)
            returnOverlay = nil
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
//        if let startAnnotation = annotation as? PointAnnotation {
        
            let startAnnotation = annotation as? PointAnnotation
        
            let oldAnnotationView = mapView.viewForAnnotation(startAnnotation)
            
            if oldAnnotationView != nil {
                return oldAnnotationView
            } else {
                
                let annotationView = MKAnnotationView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
                annotationView.backgroundColor = UIColor.redColor()
                annotationView.layer.cornerRadius = annotationView.frame.height / 2
                
                return annotationView
                
            }
            
//        } else {
//            
//            return nil
//            
//        }
        
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        
        clearOverlay()
        
        if let save = saveAnnotation {
            
            if let user = userLocation {
                
                self.locationsList.append(userLocation.coordinate)
                
                self.getLocation()
                
                var coordinates: [CLLocationCoordinate2D] = []
                
                for index in 1..<self.locationsList.count{
                    coordinates.append(self.locationsList[index])
                }
                
                returnOverlay = MKPolyline(coordinates: &coordinates, count: coordinates.count)
                
                mapView.addOverlay(returnOverlay)
                
            }
            
        }
        
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay === returnOverlay {
            let renderer = MKPolylineRenderer(overlay: returnOverlay)
            renderer.strokeColor = UIColor.redColor()
            renderer.lineCap = kCGLineCapRound
            renderer.lineWidth = 3.0
            return renderer
        }
        return nil
    }
    
    //MARK: - Refresh speed
    
    func setTimer(){
        var timer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: Selector("refreshSpeed"), userInfo: nil, repeats: true)
    }
    
    func refreshSpeed() {
        if let speed = self.currentSpeed{
            self.speedLable!.text = "Ave: \(speed) m/s"
        }else{
            self.speedLable!.text = "Ave: 0 m/s"
        }
    }
}


