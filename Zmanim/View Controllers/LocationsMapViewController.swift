//
//  LocationsMapViewController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AdAnnotation: NSObject, MKAnnotation {
    @objc var title: String?
    @objc var subtitle: String?
    @objc var coordinate: CLLocationCoordinate2D
    var annotationView: MKAnnotationView?
    
    init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil, annotationView: MKAnnotationView? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

class LocationsMapViewController: UIViewController {
    // MARK: Properties
    let locationManager = CLLocationManager()
    
    var locations: [Location]? {
        willSet {
            if locations != nil {
//                mapView?.removeAnnotations(locations!)
                //mapView?.removeAnnotation(oneStopAdAnnotation)
            }
        }
        didSet {
            // before renders and mess up!?
            if locations != nil {
//                mapView?.addAnnotations(locations!)
                //mapView?.addAnnotation(oneStopAdAnnotation)
            }
        }
    }
    var selectedLocation: Location? {
        didSet {
            tableView.reloadData()
        }
    }
    var date: Date {
        get {
            return Date()
        }
        set {
            
        }
    }
    var viewMore = false {
        didSet {
            if viewMore {
                calloutDetailView.viewMoreButton.setTitle(Constants.Map.Callout.ViewLess, for: UIControlState())
                tableViewBottomConstraint.constant = 0
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
                if #available(iOS 9.0, *) {
                    previousCamera = mapView.camera
                    let coordinatePoint = mapView.convert(selectedLocation!.coordinate, toPointTo: view)
                    let centerPoint = CGPoint(x: coordinatePoint.x, y: coordinatePoint.y - 110)
                    let centerCoordinate = mapView.convert(centerPoint, toCoordinateFrom: view)
                    if mapView.camera.pitch == 0 {
                        if mapView.camera.heading == 0 {
                            mapView.setCamera(MKMapCamera(lookingAtCenter: centerCoordinate, fromDistance: mapView.camera.altitude, pitch: 60, heading: 0), animated: true)
                        } else {
                            mapView.setCamera(MKMapCamera(lookingAtCenter: centerCoordinate, fromDistance: mapView.camera.altitude, pitch: 60, heading: mapView.camera.heading), animated: true)
                        }
                    }
                }
            } else {
                calloutDetailView.viewMoreButton.setTitle(Constants.Map.Callout.ViewMore, for: UIControlState())
                tableViewBottomConstraint.constant = tableView.frame.height
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
                mapView.setCamera(previousCamera, animated: true)
            }
        }
    }
    var firstRendering = true
    var previousCamera = MKMapCamera()
    
    //let oneStopAdAnnotation = AdAnnotation(coordinate: CLLocationCoordinate2D(latitude: Constants.Map.Annotations.Ads.OneStop.Latitude, longitude: Constants.Map.Annotations.Ads.OneStop.Longitude), title: Constants.Map.Annotations.Ads.OneStop.Title)
    
    // MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
            let center = CLLocationCoordinate2D(latitude: Constants.Map.Center.Latitude, longitude: Constants.Map.Center.Longitude)
            let region = MKCoordinateRegionMakeWithDistance(center, Constants.Map.Distance.Latitude, Constants.Map.Distance.Longitude)
            mapView.setRegion(region, animated: false)
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.allowsSelection = false
            tableView.backgroundColor = UIColor.clear
            let visualEffectView = UIVisualEffectView(frame: tableView.frame)
            visualEffectView.effect = UIBlurEffect(style: .extraLight)
            tableView.backgroundView = visualEffectView
            let separator = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: /* One pixel */ 1/UIScreen.main.scale))
            separator.backgroundColor = tableView.separatorColor
            tableView.backgroundView?.addSubview(separator)
        }
    }
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint! {
        didSet {
            tableViewBottomConstraint.constant = tableView.frame.height
        }
    }
    @IBOutlet weak var calloutDetailView: CalloutDetailView! {
        didSet {
//            calloutDetailView.delegate = self
        }
    }
    @IBOutlet weak var adCalloutView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        // TODO: if says no
        locationManager.startUpdatingLocation()
        
        //let oneStopAdAnnotationView = MKAnnotationView(annotation: oneStopAdAnnotation, reuseIdentifier: nil)
        //oneStopAdAnnotationView.image = UIImage(named: Constants.Assets.Images.OneStopMap)
        //oneStopAdAnnotation.annotationView = oneStopAdAnnotationView
        
        // TODO: if empty
        if locations == nil {
            refresh()
        }
    }
    
    // MARK: Methods
    func refresh() {
        activityIndicator.startAnimating()
        if date.isToday {
            date = Date()
        }
    }
    
    // MARK: IBActions
    @IBAction func selectFacebook(_ sender: UIButton) {
        sender.alpha = 0.5
    }
    
    @IBAction func deselectFacebook(_ sender: UIButton) {
        sender.alpha = 1
    }
    
    @IBAction func openFacebook(_ sender: UIButton) {
        sender.alpha = 1
        let url = Foundation.URL(string: Constants.URLs.Ads.OneStop.Facebook)!
        url.loadInSafariViewController(in: self)
    }
    
    @IBAction func selectInstagram(_ sender: UIButton) {
        sender.alpha = 0.5
    }
    
    @IBAction func deselectInstagram(_ sender: UIButton) {
        sender.alpha = 1
    }
    
    @IBAction func openInstagram(_ sender: UIButton) {
        sender.alpha = 1
        let url = Foundation.URL(string: Constants.URLs.Ads.OneStop.Instagram)!
        url.loadInSafariViewController(in: self)
    }
    
    @IBAction func selectYU(_ sender: UIButton) {
        sender.alpha = 0.8
    }
    
    @IBAction func deselectYU(_ sender: UIButton) {
        sender.alpha = 1
    }
    
    @IBAction func showYU(_ sender: UIButton) {
        sender.alpha = 1
        if locations != nil {
//            mapView.showAnnotations(locations!, animated: true)
        }
    }
    
    @IBAction func selectDismiss(_ sender: UIButton) {
        sender.alpha = 0.8
    }
    
    @IBAction func deselectDismiss(_ sender: UIButton) {
        sender.alpha = 1
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectRefresh(_ sender: UIButton) {
        sender.alpha = 0.8
    }
    
    @IBAction func deselectRefresh(_ sender: UIButton) {
        sender.alpha = 1
    }
    
    @IBAction func refresh(_ sender: UIButton) {
        sender.alpha = 1
        refresh()
    }
}

extension LocationsMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
}

extension LocationsMapViewController: MKMapViewDelegate {
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if firstRendering {
            if locations != nil {
//                mapView.addAnnotations(locations!)
                
                //oneStopAdAnnotation.annotationView?.frame = CGRect(x: 0, y: 0, width: 70, height: 40)
                //oneStopAdAnnotation.annotationView?.canShowCallout = true
                
                if #available(iOS 9.0, *) {
                    //oneStopAdAnnotation.annotationView?.detailCalloutAccessoryView = adCalloutView
                    let widthConstraint = NSLayoutConstraint(item: adCalloutView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 130)
                    let heightConstraint = NSLayoutConstraint(item: adCalloutView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
                    adCalloutView.addConstraints([widthConstraint, heightConstraint])
                }
                
                //mapView.addAnnotation(oneStopAdAnnotation)
//                mapView.showAnnotations(locations!, animated: true)
            }
            firstRendering = false
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // If annotation is user location keep standard
        if annotation.isKind(of: MKUserLocation.self) { return nil }
        
        if let adAnnotation = annotation as? AdAnnotation {
            return adAnnotation.annotationView
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.Map.AnnotationViewReuseIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.Map.AnnotationViewReuseIdentifier)
            annotationView!.pinTintColor = view.tintColor
            annotationView?.detailCalloutAccessoryView = calloutDetailView
            let widthConstraint = NSLayoutConstraint(item: calloutDetailView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
            let heightConstraint = NSLayoutConstraint(item: calloutDetailView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
            calloutDetailView.addConstraints([widthConstraint, heightConstraint])
            calloutDetailView.nextLabel.textColor = view.tintColor
            annotationView!.animatesDrop = true
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation
        if let location = annotation as? Location {
            selectedLocation = location
            calloutDetailView.location = location
            calloutDetailView.setupView()
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        calloutDetailView.imageView.image = nil
        if viewMore {
            viewMore = false
        }
    }
}

extension LocationsMapViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedLocation?.zmanim.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let zman = selectedLocation!.zmanim[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Storyboard.CellReuseIdentifier)!
        cell.textLabel?.text = zman.date.shortTimeString
        cell.detailTextLabel?.text = zman.tefillah.title
        cell.backgroundColor = UIColor.clear
        return cell
    }
}

//extension LocationsMapViewController: ZmanimDataSourceDelegate {
//    func handleZmanimFetchCompletion() {
//        activityIndicator.stopAnimating()
//        locations = ZmanimDataSource.dataSource.locations
//    }
//
//    func handleZmanimFetchError(_ error: NSError) {
//        activityIndicator.stopAnimating()
//        switch error.code {
//        case Constants.ErrorCodes.NoNetwork:
//            presentAlertController(
//                title: Constants.Alerts.Error.Network.Title,
//                message: Constants.Alerts.Error.Network.Message,
//                preferredStyle: .alert,
//                withCancelAction: true,
//                cancelActionTitle: Constants.Alerts.Actions.OK)
//        default:
//            presentAlertController(
//                title: Constants.Alerts.Error.Title,
//                message: Constants.Alerts.Error.Message,
//                preferredStyle: .alert,
//                withCancelAction: true,
//                cancelActionTitle: Constants.Alerts.Actions.OK)
//        }
//    }
//}
//
//extension LocationsMapViewController: CalloutDetailViewDelegate {
//    func didTouchUpInsideViewMoreWithLocation(_ location: Location) {
//        viewMore = !viewMore
//    }
//}

