//
//  LocationViewController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LocationTableViewController: UITableViewController {
    var viewModelData: LocationViewModelData!
    private var viewModel: LocationViewModel!
    
    var headerView: UIView?
    var imageView: UIImageView?
    
    struct Constants {
        static let maps = "Maps"
        static let waze = "Waze"
        static let googleMaps = "Google Maps"
        static let wazeBaseURL = "waze://"
        static let googleMapsBaseURL = "comgooglemaps://"
        static let headerViewHeight: CGFloat = 250
        static let standardRowHeight: CGFloat = 50
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = LocationViewModel(data: viewModelData)
        
        navigationItem.title = viewModel.location.title
        
        tableView.estimatedRowHeight = Constants.standardRowHeight
        
        if let locationImage = viewModel.location.image {
            headerView = UIView()
            imageView = UIImageView()
            if let headerView = headerView, let imageView = imageView {
                imageView.setImage(locationImage)
                imageView.contentMode = .scaleAspectFill
                imageView.translatesAutoresizingMaskIntoConstraints = false
                headerView.addSubview(imageView)
                headerView.addConstraints([
                    headerView.leftAnchor.constraint(equalTo: imageView.leftAnchor),
                    headerView.topAnchor.constraint(equalTo: imageView.topAnchor),
                    headerView.rightAnchor.constraint(equalTo: imageView.rightAnchor),
                    headerView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
                ])
                
                tableView.contentInset.top = Constants.headerViewHeight
                tableView.contentOffset.y = -Constants.headerViewHeight
                tableView.addSubview(headerView)
            }
        }
    }
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.item(for: indexPath)!
        switch item.key {
        case .description:
            let descriptionItem = item as! DescriptionLocationItem
            let cell = tableView.dequeueReusableCell(withIdentifier: descriptionItem.cellIdentifier.rawValue) as! DescriptionTableViewCell
            cell.descriptionLabel.text = descriptionItem.text
            return cell
        case .zman:
            let zmanItem = item as! ZmanLocationItem
            let cell = tableView.dequeueReusableCell(withIdentifier: zmanItem.cellIdentifier.rawValue)!
            cell.textLabel?.text = zmanItem.zman.date.shortTimeString
            cell.detailTextLabel?.text = zmanItem.zman.tefillah.title
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.title(for: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = viewModel.item(for: indexPath)!
        switch item.key {
        case .description:
            return UITableViewAutomaticDimension
        case .zman:
            return Constants.standardRowHeight
        }
    }
    
    // MARK: - Scroll View
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let headerView = headerView {
            var headerRect = CGRect(x: 0, y: -Constants.headerViewHeight, width: tableView.bounds.width, height: Constants.headerViewHeight)
            if tableView.contentOffset.y < -Constants.headerViewHeight {
                headerRect.origin.y = tableView.contentOffset.y
                headerRect.size.height = -tableView.contentOffset.y
            }
            headerView.frame = headerRect
        }
    }
    // MARK: -
    
    func presentNavigationAlert(for coordinate: CLLocationCoordinate2D) {
        let navigationAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let mapsAction = UIAlertAction(title: Constants.maps, style: .default) { action in
            self.openInMaps(with: coordinate)
        }
        let wazeAction = UIAlertAction(title: Constants.waze, style: .default) { action in
            self.navigateInWaze(to: coordinate)
        }
        let googleMapsAction = UIAlertAction(title: Constants.googleMaps, style: .default) { action in
            self.openInGoogleMaps(with: coordinate)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.dismiss(animated: true, completion: nil)
        }
        navigationAlertController.addAction(mapsAction)
        if URL.canOpen(Constants.wazeBaseURL) {
            navigationAlertController.addAction(wazeAction)
        }
        if URL.canOpen(Constants.googleMapsBaseURL) {
            navigationAlertController.addAction(googleMapsAction)
        }
        navigationAlertController.addAction(cancelAction)
        present(navigationAlertController, animated: true, completion: nil)
    }
    
    func openInMaps(with coordinate: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = viewModel.location.title
        mapItem.openInMaps(launchOptions: nil)
    }
    
    func navigateInWaze(to coordinate: CLLocationCoordinate2D) {
        if URL.canOpen(Constants.wazeBaseURL) {
            let urlString = "\(Constants.wazeBaseURL)?ll=\(coordinate.latitude),\(coordinate.longitude)&navigate=yes"
            URL.open(urlString)
        }
    }
    
    func openInGoogleMaps(with coordinate: CLLocationCoordinate2D) {
        if URL.canOpen(Constants.googleMapsBaseURL) {
            let urlString = "\(Constants.googleMapsBaseURL)?q=\(coordinate.latitude),\(coordinate.longitude)"
            URL.open(urlString)
        }
    }
    
    // MARK: - IBActions
    @IBAction func navigate() {
        if URL.canOpen(Constants.wazeBaseURL) {
            presentNavigationAlert(for: viewModel.location.coordinate)
        } else if URL.canOpen(Constants.googleMapsBaseURL) {
            presentNavigationAlert(for: viewModel.location.coordinate)
        } else {
            openInMaps(with: viewModel.location.coordinate)
        }
    }
}
