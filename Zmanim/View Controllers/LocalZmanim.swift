//
//  LocalZmanim.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import UIKit

class LocalZmanimTableViewController: UITableViewController, LocalZmanimTableViewControllerDataSource {
    //MARK: Properties
    var viewModel: LocalZmanimViewModel!
    var localZmanim: [LocalZman]? {
        didSet {
            tableView.reloadData()
            viewModel?.findNextLocalZman()
        }
    }
    var date: Date {
        get {
            return ZmanimDataSource.dataSource.date
        }
        set {
            ZmanimDataSource.dataSource.date = newValue
        }
    }
    var defaultSeparatorColor: UIColor!
    var nextZmanRow: Int? {
        var row: Int?
        if localZmanim != nil {
            localZmanim!.enumerated().forEach { index, zman in
                if zman.next {
                    row = index
                }
            }
        }
        return row
    }
    
    //MARK: IBOutlets
    @IBOutlet weak var headerLabel: UILabel! {
        didSet {
            setupHeaderLabelText()
        }
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = Constants.LocalZmanim.Title
        defaultSeparatorColor = tableView.separatorColor
        setupTableView()
        setupRefreshControl()
        
        viewModel = LocalZmanimViewModel(dataSource: self)
        viewModel.findNextLocalZman()
        
        localZmanim = ZmanimDataSource.dataSource.localZmanim
        
        ZmanimDataSource.dataSource.delegate = self
        if localZmanim == nil {
            refreshControl?.beginRefreshing()
            ZmanimDataSource.dataSource.fetchAndConfigureLocalZmanim()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollToNextZmanRow()
    }
    
    //MARK: Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localZmanim?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Storyboard.CellReuseIdentifier)!
        let localZman = localZmanim![indexPath.row]
        cell.textLabel?.text = localZman.title
        cell.detailTextLabel?.text = localZman.date.timeWithSecondsString
        if localZman.next {
            cell.textLabel?.textColor = tableView.tintColor
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: cell.textLabel!.font.pointSize)
            cell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: cell.detailTextLabel!.font.pointSize)
        }
        return cell
    }
    
    // MARK: Methods
    func setupTableView() {
        tableView.backgroundView = nil
        tableView.separatorColor = defaultSeparatorColor
        tableView.rowHeight = Constants.LocalZmanim.TableViewRowHeight
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(didRefresh), for: .valueChanged)
    }
    
    func setupHeaderLabelText() {
        headerLabel.text = "Washington Heights for \(date.shortDateString)"
    }
    
    func scrollToNextZmanRow() {
        if nextZmanRow != nil {
            let nextZmanIndexPath = IndexPath(row: nextZmanRow!, section: 0)
            tableView.scrollToRow(at: nextZmanIndexPath, at: .top, animated: true)
        }
    }
    
    func didRefresh() {
        if date.isToday {
            date = Date()
        }
        ZmanimDataSource.dataSource.fetchAndConfigureLocalZmanim(for: date)
        setupHeaderLabelText()
    }
}

extension LocalZmanimTableViewController: ZmanimDataSourceDelegate {
    func handleLocalZmanimFetchCompletion() {
        refreshControl?.endRefreshing()
        setupTableView()
        localZmanim = ZmanimDataSource.dataSource.localZmanim
    }
    
    func handleLocalZmanimFetchError(_ error: NSError) {
        refreshControl?.endRefreshing()
        switch error.code {
        case Constants.ErrorCodes.NoNetwork:
            tableView.setupErrorView(with: Constants.Alerts.Error.Network.Title, message: Constants.Alerts.Error.Network.Message)
        default:
            break
        }
    }
}
