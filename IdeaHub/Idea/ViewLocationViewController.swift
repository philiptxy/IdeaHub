//
//  ViewLocationViewController.swift
//  IdeaHub
//
//  Created by Philip Teow on 23/03/2018.
//  Copyright © 2018 Philip Teow. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase

class ViewLocationViewController: UIViewController, CLLocationManagerDelegate {

   
    @IBOutlet weak var mapView: MKMapView!
    
    
     var locationManager : CLLocationManager = CLLocationManager()
    var selectedIdea : Idea = Idea()
    
    var ref : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        zoomIn()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: (error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first {
//            let span = MKCoordinateSpanMake(0.05, 0.05)
//            let region = MKCoordinateRegion(center: location.coordinate, span: span)
//            mapView.setRegion(region, animated: true)
//        }
    }

    func zoomIn() {
        
        
        let coor = CLLocation(latitude: selectedIdea.lat, longitude: selectedIdea.long)
     
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coor.coordinate
            annotation.title = selectedIdea.locationName
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(coor.coordinate, span)
        mapView.setRegion(region, animated: true)
        
       
    }
    
    
    
}
