//
//  HomeViewController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import SafariServices
import DatePickerDialog

class HomeTableViewController: UITableViewController {
    var zmanim: [Zman]?
    
    var date = Date()
    
    private var viewModel = HomeViewModel()
    
    // MARK: - IBOutlets
    @IBOutlet var mapButton: UIBarButtonItem!
    @IBOutlet var dateButton: UIBarButtonItem! {
        didSet {
            setDateButtonText()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = Constants.Main.TableViewRowHeight
        clearsSelectionOnViewWillAppear = true
        tableView.tableHeaderView = nil
        
        let titleIconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        titleIconImageView.image = UIImage(named: Constants.Assets.Images.TitleIcon)!
        titleIconImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleIconImageView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setDateButtonText()
    }
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: item.cellIdentifier.rawValue)!
        cell.textLabel?.text = item.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.items[indexPath.row]
        switch item.key {
        case .tefillah:
            performSegue(withIdentifier: "showZmanim", sender: item)
        case .more: break
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch sender {
        case let tefillahItem as TefillahHomeItem:
            if let zmanimViewController = segue.destination as? ZmanimTableViewController {
                zmanimViewController.tefillah = tefillahItem.tefillah
            }
        case let barButtonItem as UIBarButtonItem:
            if barButtonItem == mapButton {
                segue.destination.transitioningDelegate = self
            }
        default: break
        }
    }
    // MARK: -
    
    func setDateButtonText() {
//        dateButton.title = date.isToday ? "Today, \(date.shortTimeString)" : date.shortDateTimeString
    }
    
    func deselectSelectedRow() {
        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRowIndexPath, animated: true)
        }
    }
    
    func openMail() {
        URL.open(Constants.URLs.EmailMe)
    }
    
    // MARK: - IBActions
    @IBAction func presentMap(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Constants.Storyboard.Main.PresentMapSegueIdentifier, sender: sender)
    }
    
    @IBAction func changeDate(_ sender: UIBarButtonItem) {
        DatePickerDialog().show("Choose a date...", defaultDate: date, minimumDate: Date(), maximumDate: Date().addingWeek(), datePickerMode: .dateAndTime) { date in
            self.date = date ?? self.date
        }
    }
}

extension HomeTableViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimatedController(duration: Constants.Main.MapLaunchTransitionDuration)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimatedController(type: .slideDown, duration: Constants.Main.MapDismissTransitionDuration)
    }
}
