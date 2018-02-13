//
//  HomeViewController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    fileprivate var viewModel = HomeViewModel()
    
    // MARK: - IBOutlets & View Properties
    @IBOutlet var tableView: UITableView!
    @IBOutlet var mapButton: UIBarButtonItem!
    @IBOutlet var dateButton: UIBarButtonItem! {
        didSet {
            setDateButtonText()
        }
    }
    @IBOutlet var calendarView: UIView!
    @IBOutlet var calendarCollectionView: CalendarCollectionView!
    
    
    var isCalendarViewHidden = true
    
    fileprivate struct Constants {
        static let defaultTableViewContentYOffset: CGFloat = -88
        static let calendarViewHeight: CGFloat = 120
        static let tableViewRowHeight: CGFloat = 100
        static let emailWithHello = "mailto:nniazoff@zmanimapp.com?subject=Hello!"
    }
    
    fileprivate enum SegueIdentifier: String {
        case showZmanim, presentMap, showLocalZmanim, showAbout
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = Constants.tableViewRowHeight
        
        // Sets title view to icon.
        let titleIconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        titleIconImageView.image = #imageLiteral(resourceName: "Title Icon")
        titleIconImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleIconImageView
        
        viewModel.getZmanim()
        
        calendarView.frame = CGRect(x: 0, y: -Constants.calendarViewHeight, width: tableView.frame.width, height: Constants.calendarViewHeight)
        calendarCollectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        
        calendarCollectionView.configureCell = { index, cell in
            let date = self.viewModel.thisWeekDates[index]
            cell.weekdayLabel.text = date.weekdayString
            cell.dayLabel.text = date.dayString
            
            if date.isToday {
                if date.isSameDay(as: self.viewModel.selectedDate) {
                    cell.backgroundColor = .strawberry
                    cell.setTextWhite()
                } else {
                    cell.backgroundColor = .white
                    cell.setDayStrawberry()
                }
            } else {
                if date.isSameDay(as: self.viewModel.selectedDate) {
                    cell.backgroundColor = .black
                    cell.setTextWhite()
                } else {
                    cell.backgroundColor = .white
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch sender {
        case let tefillahItem as TefillahHomeItem:
            if let zmanimViewController = segue.destination as? ZmanimViewController {
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
        tableView.contentInset.top = Constants.calendarViewHeight
        tableView.contentOffset.y = Constants.defaultTableViewContentYOffset
        UIView.animate(withDuration: 0.25) {
            self.tableView.contentOffset.y = Constants.defaultTableViewContentYOffset - Constants.calendarViewHeight
        }
        isCalendarViewHidden = false
    }
    
    func hideCalendarView() {
        isCalendarViewHidden = true
        UIView.animate(withDuration: 0.25, animations: {
            self.tableView.contentOffset.y = Constants.defaultTableViewContentYOffset
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

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: item.cellIdentifier.rawValue)!
        cell.textLabel?.text = item.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.items[indexPath.row]
        switch item.key {
        case .tefillah:
            performSegue(withIdentifier: SegueIdentifier.showZmanim.rawValue, sender: item)
        case .zmanim:
            performSegue(withIdentifier: SegueIdentifier.showLocalZmanim.rawValue, sender: item)
        case .more:
            performSegue(withIdentifier: SegueIdentifier.showAbout.rawValue, sender: item)
        }
    }
}

extension HomeViewController: UIViewControllerTransitioningDelegate {
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
