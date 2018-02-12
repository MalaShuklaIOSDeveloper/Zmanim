//
//  HomeViewController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    private var viewModel = HomeViewModel()
    
    // MARK: - IBOutlets & View Properties
    @IBOutlet var mapButton: UIBarButtonItem!
    @IBOutlet var dateButton: UIBarButtonItem! {
        didSet {
            setDateButtonText()
        }
    }
    @IBOutlet var calendarView: UIView!
    @IBOutlet var calendarCollectionView: CalendarCollectionView!
    
    var isCalendarViewHidden = true
    
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
        
        calendarView.frame = CGRect(x: 0, y: -100, width: tableView.frame.width, height: 100)
        
        calendarCollectionView.configureCell = { index, cell in
            let date = self.viewModel.thisWeekDates[index]
            cell.monthLabel.text = date.monthString
            cell.dayLabel.text = date.dayString
            cell.weekdayLabel.text = date.weekdayString
            
            if date.isToday {
                if date.isSameDayAs(self.viewModel.selectedDate) {
                    cell.backgroundColor = .strawberry
                    cell.layer.borderWidth = 0
                    cell.setTextWhite()
                } else {
                    cell.backgroundColor = .white
                    cell.layer.borderWidth = 0.5
                    cell.layer.borderColor = UIColor.gray.cgColor
                    cell.setDayStrawberry()
                }
            } else {
                if date.isSameDayAs(self.viewModel.selectedDate) {
                    cell.backgroundColor = self.view.tintColor
                    cell.layer.borderWidth = 0
                    cell.setTextWhite()
                } else {
                    cell.backgroundColor = .white
                    cell.layer.borderWidth = 0.5
                    cell.layer.borderColor = UIColor.gray.cgColor
                    cell.setTextBlack()
                }
            }
        }
        
        calendarCollectionView.didSelectIndex = { index in
            self.viewModel.selectedDate = self.viewModel.thisWeekDates[index]
            self.calendarCollectionView.reloadData()
            self.setDateButtonText()
            self.viewModel.getZmanim()
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
    
    func showCalendarView() {
        tableView.addSubview(calendarView)
        tableView.contentInset.top = 100
        tableView.contentOffset.y = -88
        UIView.animate(withDuration: 0.25) {
            self.tableView.contentOffset.y = -188
        }
        isCalendarViewHidden = false
    }
    
    func hideCalendarView() {
        isCalendarViewHidden = true
        UIView.animate(withDuration: 0.25, animations: {
            self.tableView.contentOffset.y = -88
        }) { completed in
            self.tableView.contentInset.top = 0
            self.calendarView.removeFromSuperview()
        }
    }
    
    func setDateButtonText() {
        dateButton.title = viewModel.selectedDate.isToday ? "Today" : viewModel.selectedDate.shortDateString
    }
    
    func openMail() {
        URL.open(Constants.emailWithHello)
    }
    
    // MARK: - IBActions
    @IBAction func didTapMapButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: SegueIdentifier.presentMap.rawValue, sender: sender)
    }
    
    @IBAction func didTapDateButton(_ sender: UIBarButtonItem) {
        if isCalendarViewHidden {
            showCalendarView()
        } else {
            hideCalendarView()
        }
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

extension UIColor {
    static var strawberry: UIColor {
        return UIColor(named: "Strawberry")!
    }
}
