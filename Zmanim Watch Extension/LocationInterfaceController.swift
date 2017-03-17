//
//  LocationInterfaceController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2016 Natanel Niazoff. All rights reserved.
//

import Foundation
import WatchKit
import CoreLocation

protocol LocationsInterfaceControllerContext {
    var location: Location! { get }
}

class LocationInterfaceController: WKInterfaceController {
    // MARK: Properties
    var contextInput: LocationsInterfaceControllerContext! {
        didSet {
            location = contextInput.location
        }
    }
    var location: Location!
    
    // MARK: IBOutlets
    @IBOutlet var descriptionLabel: WKInterfaceLabel!
    @IBOutlet var interfaceImage: WKInterfaceImage!
    @IBOutlet var interfaceMap: WKInterfaceMap!
    
    // MARK: Lifecycle
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.contextInput = context as! LocationsInterfaceControllerContext
        
        setupInterfaceForLocation()
    }
    
    // MARK: Methods
    func setupInterfaceForLocation() {
        setTitle(location.title)
        setRegionForInterfaceMapWithLocationCoordinates()
        addAnnotationToInterfaceMapWithLocationCoordinates()
        setImageForLocation()
        descriptionLabel.setText(location.directions)
    }
    
    func setImageForLocation() {
        if let locationImage = location.image {
            interfaceImage.setImage(locationImage)
        } else {
            loadLocationImageURLInInterfaceImage()
        }
    }
    
    func loadLocationImageURLInInterfaceImage() {
        if let locationImageURL = location.imageURL {
            DispatchQueue.init(label: "", qos: .userInitiated).async {
                    let imageData = try? Data(contentsOf: locationImageURL)
                    DispatchQueue.main.async {
                    if locationImageURL == self.location.imageURL {
                        if imageData != nil {
                            self.location.image = UIImage(data: imageData!)
                            self.setImageForLocation()
                        }
                    }
                }
            }
        }
    }
    
    func setRegionForInterfaceMapWithLocationCoordinates() {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 100, 100)
        interfaceMap?.setRegion(coordinateRegion)
    }
    
    func addAnnotationToInterfaceMapWithLocationCoordinates() {
        interfaceMap?.addAnnotation(location.coordinate, with: .red)
    }
}
