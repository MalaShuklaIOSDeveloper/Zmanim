//
//  LocationsViewController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LocationAnnotation: NSObject, MKAnnotation {
    let location: Location
    var coordinate: CLLocationCoordinate2D {
        return location.coordinate
    }
    
    init(location: Location) {
        self.location = location
    }
}

class LocationsViewController: UIViewController {
    let locationManager = CLLocationManager()
    
    var locationAnnotations: [LocationAnnotation]? {
        willSet {
            if let oldLocations = locationAnnotations {
                mapView?.removeAnnotations(oldLocations)
            }
        }
        didSet {
            if let newLocations = locationAnnotations {
                mapView?.addAnnotations(newLocations)
                mapView?.showAnnotations(newLocations, animated: true)
            }
        }
    }
    
    struct Constants {
        static let centerLatitude = 40.8507522
        static let centerLongitude = -73.931190
        static let distanceLatitude = 6000.0
        static let distanceLongitude = 6000.0
    }
    
    enum SegueIdentifier: String {
        case showLocation
    }
    
    enum AnnotationViewReuseIdentifier: String {
        case pinView
    }
    
    // MARK: - IBOutlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        let center = CLLocationCoordinate2D(latitude: Constants.centerLatitude, longitude: Constants.centerLongitude)
        let region = MKCoordinateRegionMakeWithDistance(center, Constants.distanceLatitude, Constants.distanceLongitude)
        mapView.setRegion(region, animated: false)
        
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        
        if let locations = ZmanimDataStore.shared.locations {
            locationAnnotations = locations.map { LocationAnnotation(location: $0) }
        } else {
            activityIndicator.startAnimating()
            ZmanimAPIClient.fetchZmanim(for: Date()) { result in
                self.activityIndicator.stopAnimating()
                switch result {
                case .success:
                    if let locations = ZmanimDataStore.shared.locations {
                        self.locationAnnotations = locations.map { LocationAnnotation(location: $0) }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifierString = segue.identifier, let identifier = SegueIdentifier(rawValue: identifierString) {
            switch identifier {
            case .showLocation:
                if let locationTableViewController = segue.destination as? LocationTableViewController, let locationAnnotation = sender as? LocationAnnotation {
                    locationTableViewController.viewModelData = LocationViewModelData(location: locationAnnotation.location)
                }
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func selectDismiss(_ sender: UIButton) {
        sender.alpha = 0.8
    }
    
    @IBAction func deselectDismiss(_ sender: UIButton) {
        sender.alpha = 1
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension LocationsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
}

extension LocationsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationViewReuseIdentifier.pinView.rawValue) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: AnnotationViewReuseIdentifier.pinView.rawValue)
            annotationView!.pinTintColor = view.tintColor
        } else {
            annotationView!.annotation = annotation
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation
        if let locationAnnotation = annotation as? LocationAnnotation {
            performSegue(withIdentifier: SegueIdentifier.showLocation.rawValue, sender: locationAnnotation)
        }
    }
}
