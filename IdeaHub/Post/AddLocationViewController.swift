//
//  AddLocationViewController.swift
//  IdeaHub
//
//  Created by Philip Teow on 22/03/2018.
//  Copyright © 2018 Philip Teow. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark, address: String)
}

class AddLocationViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var searchButton: UIButton! {
        didSet {
            searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        }
    }
    
    @objc func searchButtonTapped() {
        locationManager.startUpdatingLocation()
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var nameOfPlaceLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var confirmButton: UIButton! {
        didSet {
            confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        }
    }
    
    @objc func confirmButtonTapped() {
        //addLocation()
        
        self.navigationController?.popViewController(animated: true)
        let previousViewController = self.navigationController?.viewControllers.last as! PostViewController
        
        guard let locationName = selectedPin?.name else {return}
        previousViewController.lat = selectedLat
        previousViewController.long = selectedLong
        previousViewController.locationName = locationName
    }
    
    var locationManager : CLLocationManager = CLLocationManager()
    
    var resultSearchController:UISearchController? = nil
    
    var selectedPin:MKPlacemark? = nil
    
    var selectedLat : Double = 0
    
    var selectedLong : Double = 0

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //LOCATION MANAGER
        locationManager.delegate = self 
        locationManager.desiredAccuracy = kCLLocationAccuracyBest 
        locationManager.requestWhenInUseAuthorization() 
        locationManager.requestLocation()
        
        //SEARCH CONTROLLER
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        //SEARCH BAR
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        //MORE
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
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
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    

//    func searchNearbyPlacemarks(placemark : CLPlacemark) {
//        //need to create local search request
//        var request = MKLocalSearchRequest()
//
//        var span : MKCoordinateSpan = MKCoordinateSpanMake(1.0, 1.0)
//
//        //set how far im willing to search from centre
//
//        guard let coor = placemark.location?.coordinate else {return}
//
//        request.region = MKCoordinateRegionMake(coor, span)
//
//        //set query / what am i looking for
//        request.naturalLanguageQuery = self.textField.text;
//
//        //make search task
//        let search = MKLocalSearch(request: request)
//
//        search.start { (response, error) in
//            if let validError = error {
//                print(validError.localizedDescription)
//            }
//
//            if let validResponse = response {
//                let item = validResponse.mapItems.first
//
//                guard let nameOfPlace = item?.name,
//                    let lat = item?.placemark.location?.coordinate.latitude,
//                    let long = item?.placemark.location?.coordinate.longitude else {return}
//
//                print("LOCATION FOUND: %@\nCoordinates: %f || %f",nameOfPlace, lat, long)
//
//
//
//            }
//        }
//    }

}

extension AddLocationViewController : HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark, address: String){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "(city) (state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        
        selectedLat = placemark.coordinate.latitude
        selectedLong = placemark.coordinate.longitude
            
        showOnBottomView(placemark: placemark, address: address)
        
    }
    
    func showOnBottomView(placemark: MKPlacemark, address: String) {
        bottomView.isHidden = false
        nameOfPlaceLabel.text = placemark.name
        addressLabel.text = address
        
    }
}
