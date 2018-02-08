//
//  ZmanimViewController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class ZmanimTableViewController: UITableViewController {
    
    var viewModel = ZmanimViewModel()
    
    var tefillah = Tefillah.shacharis
    
    var zmanim: [Zman]?
    
    var date = Date()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = tefillah.title
        clearsSelectionOnViewWillAppear = true
        setupTableView()
        
        setupRefreshControl()
        
        if let tefillahZmanim = ZmanimDataStore.shared.zmanim(for: tefillah) {
            zmanim = tefillahZmanim
            setupTableView()
            tableView.reloadData()
        } else {
            ZmanimAPIClient.fetchZmanim(for: Date()) { result in
                switch result {
                case .success(let value):
                    self.zmanim = value[self.tefillah]
                    self.setupTableView()
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return zmanim?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zmanim![section].locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "zmanCell") as! ZmanTableViewCell
        let zman = zmanim![indexPath.section]
        let location = zman.locations[indexPath.row]
        cell.locationLabel.text = location.title
        cell.tefillah = zman.tefillah
        cell.zman = zman
        cell.location = location
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let zman = zmanim![section]
        return zman.date.shortTimeString
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !zmanim![indexPath.section].locations[indexPath.row].recognized {
            presentAlertController(
                title: Constants.Alerts.UnknownLocation.Title,
                message: Constants.Alerts.UnknownLocation.Message,
                withCancelAction: true,
                cancelActionTitle: Constants.Alerts.Actions.OK,
                cancelActionHandler: { action in
                    self.deselectSelectedRow()
                })
        } else {
            performSegue(withIdentifier: Constants.Storyboard.Zmanim.ShowLocationSegueIdentifier, sender: indexPath)
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Constants.Storyboard.Zmanim.ShowLocationSegueIdentifier:
                if let locationViewController = segue.destination as? LocationTableViewController {
                    if let indexPath = sender as? IndexPath {
                        locationViewController.location = zmanim![indexPath.section].locations[indexPath.row]
                    }
                }
            default:
                break
            }
        }
    }
    // MARK: -
    
    func setupTableView() {
        refreshControl?.endRefreshing()
        tableView.backgroundView = nil
        tableView.rowHeight = Constants.Zmanim.TableViewRowHeight
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(didRefresh), for: .valueChanged)
        // In the case that zmanim is nil and is fetching begins animation
        if zmanim == nil {
            refreshControl?.beginRefreshing()
        }
    }
    
    func didRefresh() {
        if date.isToday {
            date = Date()
        }
    }
    
    // TODO: change to global if needed
    func deselectSelectedRow() {
        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRowIndexPath, animated: true)
        } 
    }
    
    func setupNoZmanimView() {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height))
        titleLabel.center = tableView.center
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.lightGray
        titleLabel.font = UIFont.systemFont(ofSize: Constants.Alerts.Zmanim.NoZmanim.TextSize)
        titleLabel.text = Constants.Alerts.Zmanim.NoZmanim.Title
        titleLabel.sizeToFit()
        tableView.backgroundView = titleLabel
        tableView.separatorColor = UIColor.clear
    }
}
