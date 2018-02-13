//
//  ZmanimViewController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class ZmanimViewController: UIViewController {
    var viewModelData: ZmanimViewModelData!
    fileprivate var viewModel: ZmanimViewModel!
    
    // MARK: - IBOutlets & View Properties
    @IBOutlet var tableView: UITableView!
    @IBOutlet var errorView: UIView!
    @IBOutlet var errorTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var errorActivityIndicator: UIActivityIndicatorView!
    
    fileprivate struct Constants {
        static let tableViewRowHeight: CGFloat = 60
    }
    
    fileprivate enum SegueIdentifier: String {
        case showLocation
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = ZmanimViewModel(data: viewModelData)
        
        navigationItem.title = viewModel.tefillah.title
        tableView.rowHeight = Constants.tableViewRowHeight
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didRefresh), for: .valueChanged)
        errorView.translatesAutoresizingMaskIntoConstraints = false
        
        getZmanim()
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
    
    func getZmanim() {
        tableView.refreshControl?.beginRefreshing()
        errorActivityIndicator.startAnimating()
        viewModel.getZmanim { result in
            switch result {
            case .success:
                self.tableView.reloadData()
                if self.errorView.isDescendant(of: self.view) {
                    self.removeErrorView()
                }
            case .error:
                self.addErrorView()
            }
            self.tableView.refreshControl?.endRefreshing()
            self.errorActivityIndicator.stopAnimating()
        }
    }
    
    func didRefresh() {
        getZmanim()
    }
    
    func addErrorView() {
        view.addSubview(errorView)
        view.bringSubview(toFront: errorView)
        errorView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        errorView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        errorView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        view.addGestureRecognizer(errorTapGestureRecognizer)
    }
    
    func removeErrorView() {
        errorView.removeFromSuperview()
        view.removeGestureRecognizer(errorTapGestureRecognizer)
    }
    
    // MARK: - IBActions
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        didRefresh()
    }
}

extension ZmanimViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.zmanCellIdentifier.rawValue) as! ZmanTableViewCell
        
        if let zman = viewModel.zman(for: indexPath.section) {
            let location = zman.locations[indexPath.row]
            cell.locationLabel.text = location.title
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let zman = viewModel.zman(for: section) {
            return zman.date.shortTimeString
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let zman = viewModel.zman(for: indexPath.section) {
            if zman.locations[indexPath.row].recognized {
                performSegue(withIdentifier: SegueIdentifier.showLocation.rawValue, sender: indexPath)
            }
        }
    }
}
