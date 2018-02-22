//
//  HomeViewController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    let viewModelData = HomeViewModelData()
    fileprivate var viewModel: HomeViewModel!
    
    // MARK: - IBOutlets & View Properties
    @IBOutlet var tableView: UITableView!
    @IBOutlet var mapButton: UIBarButtonItem!
    @IBOutlet var dateButton: UIBarButtonItem!
    @IBOutlet var calendarView: UIView!
    @IBOutlet var calendarCollectionView: SelectionCollectionView!
    @IBOutlet var shnayimView: UIView!
    
    let isiPhoneX = UIScreen.main.nativeBounds.height == 2436
    var isCalendarViewHidden = true
    var defaultTableViewContentYOffset: CGFloat {
        return isiPhoneX ? -88 : -64
    }
    
    fileprivate struct Constants {
        static let calendarViewHeight: CGFloat = 120
        static let tableViewRowHeight: CGFloat = 100
        static let shnayimViewHeight: CGFloat = 90
        static let emailWithHello = "mailto:nniazoff@zmanimapp.com?subject=Hello!"
        static let shnayimAppStore = "itms-apps://itunes.apple.com/app/id1296709500"
    }
    
    enum CellIdentifier: String {
        case calendarCell
    }
    
    fileprivate enum SegueIdentifier: String {
        case showZmanim, presentMap, showLocalZmanim, showAbout
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = HomeViewModel(data: viewModelData)
        
        tableView.rowHeight = Constants.tableViewRowHeight
        
        // Sets title view to icon.
        let titleIconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        titleIconImageView.image = #imageLiteral(resourceName: "Title Icon")
        titleIconImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleIconImageView
        setDateButtonText()
        
        registerForPreviewing(with: self, sourceView: tableView)
        
        viewModel.getZmanim()
        
        calendarView.frame = CGRect(x: 0, y: -Constants.calendarViewHeight, width: tableView.frame.width, height: Constants.calendarViewHeight)
        calendarCollectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        calendarCollectionView.numberOfItems = { self.viewModel.thisWeekDates.count }
        calendarCollectionView.cellReuseIdentifier = CellIdentifier.calendarCell.rawValue
        
        calendarCollectionView.configureCell = { index, cell in
            let date = self.viewModel.thisWeekDates[index]
            if let calendarCell = cell as? CalendarCell {
                calendarCell.weekdayLabel.text = date.weekdayString
                calendarCell.dayLabel.text = date.dayString
                
                if date.isToday {
                    if date.isSameDay(as: self.viewModel.selectedDate) {
                        calendarCell.backgroundColor = .strawberry
                        calendarCell.setTextWhite()
                    } else {
                        calendarCell.backgroundColor = .white
                        calendarCell.setDayStrawberry()
                    }
                } else {
                    if date.isSameDay(as: self.viewModel.selectedDate) {
                        calendarCell.backgroundColor = .black
                        calendarCell.setTextWhite()
                    } else {
                        calendarCell.backgroundColor = .white
                        calendarCell.setTextBlack()
                    }
                }
            }
        }
        
        calendarCollectionView.didSelectIndex = { index in
            self.viewModel.selectedDate = self.viewModel.thisWeekDates[index]
            self.calendarCollectionView.reloadData()
            self.setDateButtonText()
            self.viewModel.getZmanim()
        }
        
        shnayimView.layer.masksToBounds = false
        shnayimView.layer.cornerRadius = 15
        shnayimView.layer.shadowOpacity = 0.2
        shnayimView.layer.shadowRadius = 8
        shnayimView.layer.shadowOffset = CGSize.zero
        view.addSubview(shnayimView)
        shnayimView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shnayimView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            shnayimView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: shnayimView.bottomAnchor, constant: isiPhoneX ? 0 : 20),
            shnayimView.heightAnchor.constraint(equalToConstant: Constants.shnayimViewHeight)
        ])
        tableView.contentInset.bottom = shnayimView.frame.height + (isiPhoneX ? 0 : 20)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Deselect selected row.
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Reload collection view in case new date.
        calendarCollectionView.reloadData()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch sender {
        case let tefillahItem as TefillahHomeItem:
            if let zmanimViewController = segue.destination as? ZmanimViewController {
                zmanimViewController.viewModelData = ZmanimViewModelData(tefillah: tefillahItem.tefillah, highlightZmanDate: viewModel.highlightZmanDate, highlightLocationTitle: viewModel.highlightLocationTitle)
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
        dateButton?.title = viewModel.selectedDate.isToday ? "Today" : viewModel.selectedDate.shortDateString
    }
    
    func showCalendarView() {
        calendarView.frame = CGRect(x: 0, y: -Constants.calendarViewHeight, width: tableView.frame.width, height: Constants.calendarViewHeight)
        tableView.addSubview(calendarView)
        tableView.contentInset.top = Constants.calendarViewHeight
        tableView.contentOffset.y = defaultTableViewContentYOffset
        UIView.animate(withDuration: 0.25) {
            self.tableView.contentOffset.y = self.defaultTableViewContentYOffset - Constants.calendarViewHeight
        }
        isCalendarViewHidden = false
    }
    
    func hideCalendarView() {
        isCalendarViewHidden = true
        UIView.animate(withDuration: 0.25, animations: {
            self.tableView.contentOffset.y = self.defaultTableViewContentYOffset
        }) { completed in
            self.tableView.contentInset.top = 0
            self.calendarView.removeFromSuperview()
        }
    }
    
    func selectInitialIndexPath() {
        if let indexPath = viewModel.initialIndexPath {
            // Go to today if at another date.
            if !viewModel.selectedDate.isToday,
                let today = viewModel.thisWeekDates.first {
                viewModel.selectedDate = today
                calendarCollectionView?.reloadData()
                setDateButtonText()
                viewModel.getZmanim()
            }
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { timer in
                self.tableView(self.tableView, didSelectRowAt: indexPath)
                // Clear notification sent to app by user.
                self.viewModelData.notification = nil
            }
        }
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
    
    @IBAction func didTapShnayimViewButton(_ sender: UIButton) {
        URL.open(Constants.shnayimAppStore)
        viewModel.logDidTapShnayim()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
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
            if let tefillahItem = item as? TefillahHomeItem {
                viewModel.logDidTapTefillah(with: tefillahItem)
            }
        case .zmanim:
            performSegue(withIdentifier: SegueIdentifier.showLocalZmanim.rawValue, sender: item)
        case .more:
            performSegue(withIdentifier: SegueIdentifier.showAbout.rawValue, sender: item)
        }
    }
}

// MARK: - UIViewControllerPreviewingDelegate
extension HomeViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
            if let item = viewModel.item(for: indexPath) {
                switch item.key {
                case .tefillah:
                    let tefillahItem = item as! TefillahHomeItem
                    if let zmanimViewController = storyboard?.instantiateViewController(withIdentifier: ZmanimViewController.storyboardID) as? ZmanimViewController {
                        zmanimViewController.viewModelData = ZmanimViewModelData(tefillah: tefillahItem.tefillah, highlightZmanDate: viewModel.highlightZmanDate, highlightLocationTitle: viewModel.highlightLocationTitle)
                        return zmanimViewController
                    }
                case .zmanim:
                    if let localZmanimViewController = storyboard?.instantiateViewController(withIdentifier: LocalZmanimViewController.storyboardID) as? LocalZmanimViewController {
                        return localZmanimViewController
                    }
                default: break
                }
            }
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: false)
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
    
    static var shnayimBrown: UIColor {
        return UIColor(named: "Shnayim Brown")!
    }
}
