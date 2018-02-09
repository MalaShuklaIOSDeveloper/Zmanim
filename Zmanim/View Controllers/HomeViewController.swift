//
//  HomeViewController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    /// The date for zmanim.
    var date = Date()
    
    private var viewModel = HomeViewModel()
    
    // MARK: - IBOutlets
    @IBOutlet var mapButton: UIBarButtonItem!
    @IBOutlet var dateButton: UIBarButtonItem! {
        didSet {
            setDateButtonText()
        }
    }
    
    private struct Constants {
        static let tableViewRowHeight: CGFloat = 100
        static let emailWithHello = "mailto:nniazoff@zmanimapp.com?subject=Hello!"
    }
    
    private enum SegueIdentifier: String {
        case showZmanim, presentMap
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = Constants.tableViewRowHeight
        clearsSelectionOnViewWillAppear = true
        
        // Sets title view to icon.
        let titleIconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        titleIconImageView.image = #imageLiteral(resourceName: "Title Icon")
        titleIconImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleIconImageView
        
        viewModel.getZmanim()
    }
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
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
            performSegue(withIdentifier: SegueIdentifier.showZmanim.rawValue, sender: item)
        case .more: break
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch sender {
        case let tefillahItem as TefillahHomeItem:
            if let zmanimViewController = segue.destination as? ZmanimTableViewController {
                zmanimViewController.viewModelData = ZmanimViewModelData(tefillah: tefillahItem.tefillah)
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
        dateButton.title = date.isToday ? "Today" : date.shortDateTimeString
    }
    
    func openMail() {
        URL.open(Constants.emailWithHello)
    }
    
    // MARK: - IBActions
    @IBAction func presentMap(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: SegueIdentifier.presentMap.rawValue, sender: sender)
    }
    
    @IBAction func changeDate(_ sender: UIBarButtonItem) {
        
    }
}

extension HomeTableViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimatedController(duration: 0.25)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimatedController(type: .slideDown, duration: 0.25)
    }
}
