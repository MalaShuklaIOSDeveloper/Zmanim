//
//  ZmanimViewController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import UIKit
import UserNotifications

class ZmanimTableViewController: UITableViewController, ZmanimTableViewControllerDataSource {
    // MARK: Properties
    var viewModel: ZmanimViewModel!
    var tefillah = Tefillah.shacharis
    var zmanim: [Zman]? {
        didSet {
            nextZman = viewModel?.findNextZman()
            
            // Reloads the table view's data everytime updated
            tableView.reloadData()
            setupNextButton()
            
            if zmanim == nil {
                if !ZmanimDataSource.dataSource.isFetchingZmanim {
                    ZmanimDataSource.dataSource.fetchAndConfigureZmanim(for: Date())
                }
            } else {
                if zmanim!.isEmpty {
                    setupNoZmanimView()
                }
            }
        }
    }
    var date: Date {
        get {
            return ZmanimDataSource.dataSource.date
        } set {
            ZmanimDataSource.dataSource.date = newValue
        }
    }
    var nextZman: Zman?
    
    var nextZmanSection: Int? {
        var section: Int?
        if zmanim != nil {
            zmanim!.enumerated().forEach { index, zman in
                if zman.next {
                    section = index
                }
            }
        }
        return section
    }
    
    var viewDidAppearHasRun = false
    var zmanimTimers = [Timer]()
    
    var defaultSeparatorColor: UIColor!
    
    //IBOutlets
    @IBOutlet weak var nextButton: UIBarButtonItem! {
        didSet {
            setupNextButton()
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = tefillah.title
        clearsSelectionOnViewWillAppear = true
        tableView.delaysContentTouches = false
        defaultSeparatorColor = tableView.separatorColor
        setupTableView()
        
        for case let scrollView as UIScrollView in tableView.subviews {
            scrollView.delaysContentTouches = false
        }
        
        // TODO: set to nil after leaving
        ZmanimDataSource.dataSource.delegate = self

        viewModel = ZmanimViewModel(dataSource: self)
        viewModel.findNextZman()
        
        setupRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ZmanimDataSource.dataSource.delegate = self
        
        // When returning to this view the selected row is deselected.
        deselectSelectedRow()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !viewDidAppearHasRun {
            scrollToNextZmanSection()
        }
        
        viewDidAppearHasRun = true
    }
    
    // MARK: Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return zmanim?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zmanim![section].locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Storyboard.Zmanim.ZmanCellReuseIdentifier) as! ZmanTableViewCell
        let zman = zmanim![indexPath.section]
        let location = zman.locations[indexPath.row]
        cell.locationLabel.text = location.title
        cell.delegate = self
        cell.tefillah = zman.tefillah
        cell.zman = zman
        cell.location = location
        
        // TODO: switch block to cell
        cell.notifyButton.isHidden = false
        if let dateFiveMinutePrior = (Calendar.current as NSCalendar).date(byAdding: .minute, value: -5, to: zman.date as Date, options: NSCalendar.Options()) {
            if dateFiveMinutePrior.isLessThanDate(Date()) {
                cell.notifyButton.isHidden = true
            }
        }
        
        cell.getNotificationActionsWithPendingRequests { actions in
            if !actions.isEmpty {
                cell.atLeastOneNotificationScheduled = true
                actions.forEach { $0.notificationIsPending = true }
            } else {
                cell.atLeastOneNotificationScheduled = false
                cell.notificationActions.forEach { $0.notificationIsPending = false }
            }
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let zman = zmanim![section]
        return zman.date.shortTimeString
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if zmanim![section].next {
            let nextZmanHeaderView = SectionTitleHeaderView(title: zmanim![section].date.shortTimeString, titleColor: UIColor.white, backgroundColor: view.tintColor)
            return nextZmanHeaderView
        }
        return nil
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
    
    // MARK: Methods
    func setupTableView() {
        tableView.backgroundView = nil
        tableView.separatorColor = defaultSeparatorColor
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
    
    func setupNextButton() {
        if nextZmanSection == nil {
            nextButton?.isEnabled = false
        } else {
            nextButton?.isEnabled = true
        }
    }
    
    func didRefresh() {
        if date.isToday {
            date = Date()
        }
        ZmanimDataSource.dataSource.fetchAndConfigureZmanim(for: date)
    }
    
    // TODO: change to global if needed
    func deselectSelectedRow() {
        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRowIndexPath, animated: true)
        } 
    }
    
    func scrollToNextZmanSection() {
        if nextZmanSection != nil {
            let nextZmanIndexPath = IndexPath(row: 0, section: nextZmanSection!)
            tableView.scrollToRow(at: nextZmanIndexPath, at: .top, animated: true)
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
    
    // MARK: IBActions
    @IBAction func nextButton(_ sender: UIBarButtonItem) {
        scrollToNextZmanSection()
    }
}

extension ZmanimTableViewController: ZmanimDataSourceDelegate {
    func handleZmanimFetchCompletion() {
        refreshControl?.endRefreshing()
        setupTableView()
        zmanim = ZmanimDataSource.dataSource.zmanimForTefillah(tefillah)
    }
    
    func handleZmanimFetchError(_ error: NSError) {
        refreshControl?.endRefreshing()
        switch error.code {
        case Constants.ErrorCodes.NoNetwork:
            if zmanim == nil {
                // TODO: make reusable
                tableView.setupErrorView(with: Constants.Alerts.Error.Network.Title, message: Constants.Alerts.Error.Network.Message)
            } else {
                // TODO: use will set
                zmanim = nil
            }
        default:
            break
        }
    }
}

extension ZmanimTableViewController: ZmanTableViewCellDelegate {
    func notifyButtonTappedInZmanCell(_ cell: ZmanTableViewCell) {
        cell.getNotificationActionsWithPendingRequests { actions in
            if !actions.isEmpty {
                cell.atLeastOneNotificationScheduled = true
                actions.forEach { $0.notificationIsPending = true }
            } else {
                cell.atLeastOneNotificationScheduled = false
                cell.notificationActions.forEach { $0.notificationIsPending = false }
            }
            
            self.present(cell.notifyAlertController, animated: true, completion: nil)
        }
    }
}
