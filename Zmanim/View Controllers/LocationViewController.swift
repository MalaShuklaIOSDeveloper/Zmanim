//
//  LocationViewController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

private class Section {
    let title: String?
    let cells: [Cell]
    
    init(title: String? = nil, cells: [Cell]) {
        self.title = title
        self.cells = cells
    }
}
private class Cell {
    let cell: UITableViewCell
    let height: CGFloat
    
    init(cell: UITableViewCell, height: CGFloat = Constants.Location.DefaultCellHeight) {
        self.cell = cell
        self.height = height
    }
}

//TODO: add navigation
class LocationTableViewController: UITableViewController {
    // MARK: Properties
    var location: Location!
    fileprivate var sections = [Section]()
    fileprivate var headerView: UIView! {
        didSet {
            if headerView != nil {
                tableView.setup(headerView, with: Constants.Location.TableViewHeaderViewHeight, in: self)
                imageView.setup(with: location, animated: true, activityIndicator: imageViewActivityIndicatorView) {
                    let errorMessageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.imageView.bounds.width, height: self.imageView.bounds.height))
                    errorMessageLabel.text = Constants.Alerts.Location.Error.Image.Message
                    errorMessageLabel.textAlignment = .center
                    errorMessageLabel.center = self.imageView.center
                    self.imageView.addSubview(errorMessageLabel)
                }
            }
        }
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewActivityIndicatorView: UIActivityIndicatorView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        tableView.estimatedRowHeight = Constants.Location.DefaultCellHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        navigationItem.title = location.title
        headerView = tableView.tableHeaderView!
        
        let descriptionCell = tableView.dequeueReusableCell(withIdentifier: Constants.Storyboard.Location.DescriptionCellReuseIdentifier) as! DescriptionTableViewCell
        descriptionCell.descriptionLabel.text = location.directions
        
        var zmanimCells = [Cell]()
        for zman in location.zmanim {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Storyboard.Location.SubtitleCellReuseIdentifier)!
            cell.textLabel?.text = zman.date.shortTimeString
            cell.detailTextLabel?.text = zman.tefillah.title
            let zmanCell = Cell(cell: cell)
            zmanimCells.append(zmanCell)
        }
        
        sections = [
            Section(title: Constants.Location.DescriptionSectionTitle, cells: [
                Cell(cell: descriptionCell, height: UITableViewAutomaticDimension)
            ]),
            Section(title: Constants.Location.TodaysScheduleSectionTitle, cells: zmanimCells)
        ]
    }
    
    // MARK: Table View Data Source/Delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sections[indexPath.section].cells[indexPath.row].cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[indexPath.section].cells[indexPath.row].height
    }
    
    // MARK: IBActions
    @IBAction func navigate() {
        if URL.canOpen(Constants.URLs.Waze) {
            presentAlertForNavigationWithCoordinate(location.coordinate)
        } else if URL.canOpen(Constants.URLs.GoogleMaps) {
            presentAlertForNavigationWithCoordinate(location.coordinate)
        } else {
            openInMapsWithCoordinate(location.coordinate)
        }
    }
    
    // MARK: Methods
    func presentAlertForNavigationWithCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let navigationAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let mapsAction = UIAlertAction(title: Constants.Alerts.Location.Navigation.MapsActionTitle, style: .default) { action in
            self.openInMapsWithCoordinate(coordinate)
        }
        let wazeAction = UIAlertAction(title: Constants.Alerts.Location.Navigation.WazeActionTitle, style: .default) { action in
            self.openInWazeWithCoordinate(coordinate)
        }
        let googleMapsAction = UIAlertAction(title: Constants.Alerts.Location.Navigation.GoogleMapsActionTitle, style: .default) { action in
            self.openInGoogleMapsWithCoordinate(coordinate)
        }
        let cancelAction = UIAlertAction(title: Constants.Alerts.Actions.Cancel, style: .cancel) { action in
            self.dismiss(animated: true, completion: nil)
        }
        navigationAlertController.addAction(mapsAction)
        if URL.canOpen(Constants.URLs.Waze) {
            navigationAlertController.addAction(wazeAction)
        }
        if URL.canOpen(Constants.URLs.GoogleMaps) {
            navigationAlertController.addAction(googleMapsAction)
        }
        navigationAlertController.addAction(cancelAction)
        present(navigationAlertController, animated: true, completion: nil)
    }
    
    func openInMapsWithCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = location.title
        mapItem.openInMaps(launchOptions: nil)
    }
    
    func openInWazeWithCoordinate(_ coordinate: CLLocationCoordinate2D) {
        if URL.canOpen(Constants.URLs.Waze) {
            let urlString = "\(Constants.URLs.WazeWithCoordinate)\(coordinate.latitude),\(coordinate.longitude)\(Constants.URLs.WazeAddNavigation)"
            URL.open(urlString)
        }
    }
    
    func openInGoogleMapsWithCoordinate(_ coordinate: CLLocationCoordinate2D) {
        if URL.canOpen(Constants.URLs.GoogleMaps) {
            let urlString = "\(Constants.URLs.GoogleMapsWithCoordinate)\(coordinate.latitude),\(coordinate.longitude)"
            URL.open(urlString)
        }
    }
    
    // MARK: Scroll View Delegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tableView.update(headerView, with: Constants.Location.TableViewHeaderViewHeight)
    }
}
