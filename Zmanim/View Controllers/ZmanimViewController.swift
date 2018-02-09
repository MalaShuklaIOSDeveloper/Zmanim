//
//  ZmanimViewController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class ZmanimTableViewController: UITableViewController {
    var viewModelData: ZmanimViewModelData!
    private var viewModel: ZmanimViewModel!
    
    private struct Constants {
        static let tableViewRowHeight: CGFloat = 52
    }
    
    private enum SegueIdentifier: String {
        case showLocation
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = ZmanimViewModel(data: viewModelData)
        
        navigationItem.title = viewModel.tefillah.title
        tableView.rowHeight = Constants.tableViewRowHeight
        clearsSelectionOnViewWillAppear = true
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(didRefresh), for: .valueChanged)
        refreshControl?.beginRefreshing()
        
        viewModel.getZmanim {
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.zmanCellIdentifier.rawValue) as! ZmanTableViewCell
        
        if let zman = viewModel.zman(for: indexPath.section) {
            let location = zman.locations[indexPath.row]
            cell.locationLabel.text = location.title
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let zman = viewModel.zman(for: section) {
            return zman.date.shortTimeString
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let zman = viewModel.zman(for: indexPath.section) {
            if zman.locations[indexPath.row].recognized {
                performSegue(withIdentifier: SegueIdentifier.showLocation.rawValue, sender: indexPath)
            }
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifierString = segue.identifier, let identifier = SegueIdentifier(rawValue: identifierString) {
            switch identifier {
            case .showLocation:
                if let locationViewController = segue.destination as? LocationTableViewController, let indexPath = sender as? IndexPath, let zman = viewModel.zman(for: indexPath.section) {
                        locationViewController.viewModelData = LocationViewModelData(location: zman.locations[indexPath.row])
                }
                
            }
        }
    }
    // MARK: -
    
    func didRefresh() {
        
    }
}
