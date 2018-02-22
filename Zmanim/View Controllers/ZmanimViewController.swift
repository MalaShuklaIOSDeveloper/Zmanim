//
//  ZmanimViewController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class ZmanimViewController: UIViewController {
    static let storyboardID = "zmanimViewController"
    var viewModelData: ZmanimViewModelData!
    fileprivate var viewModel: ZmanimViewModel!
    
    // MARK: - IBOutlets & View Properties
    @IBOutlet var tableView: UITableView!
    @IBOutlet var nextButton: UIBarButtonItem!
    @IBOutlet var minutesView: UIView!
    @IBOutlet var minutesCollectionView: SelectionCollectionView!
    @IBOutlet var nothingView: UIView!
    @IBOutlet var errorView: UIView!
    @IBOutlet var errorTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var errorActivityIndicator: UIActivityIndicatorView!
    
    /// The table view content offset before adjustments from minutes view.
    var contentOffsetBeforeMinutesViewY: CGFloat?
    var isMinutesViewAnimating = false
    let isiPhoneX = UIScreen.main.nativeBounds.height == 2436
    
    fileprivate struct Constants {
        static let tableViewRowHeight: CGFloat = 60
        static let sectionHeaderViewHeight: CGFloat = 36
        static let minutesViewHeight: CGFloat = 150
    }
    
    fileprivate enum CellIdentifier: String {
        case minutesCell
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
        nothingView.translatesAutoresizingMaskIntoConstraints = false
        
        setupNextButton()
        
        registerForPreviewing(with: self, sourceView: tableView)
        
        getZmanim()
        
        minutesView.layer.masksToBounds = false
        minutesView.layer.cornerRadius = 15
        minutesView.layer.shadowOpacity = 0.1
        minutesView.layer.shadowRadius = 8
        minutesView.layer.shadowOffset = CGSize.zero
        view.addSubview(minutesView)
        minutesView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            minutesView.heightAnchor.constraint(equalToConstant: Constants.minutesViewHeight),
            minutesView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            minutesView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: minutesView.bottomAnchor, constant: isiPhoneX ? 0 : 20),
        ])
        hideMinutesView(false)
        
        minutesCollectionView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 20, right: 0)
        minutesCollectionView.backgroundColor = .clear
        minutesCollectionView.cellReuseIdentifier = CellIdentifier.minutesCell.rawValue
        
        minutesCollectionView.numberOfItems = {
            self.viewModel.selectedNotificationMinutes.count
        }
        
        minutesCollectionView.configureCell = { (index, cell) in
            if let minutesCell = cell as? MinutesCell {
                let minutes = self.viewModel.selectedNotificationMinutes[index]
                minutesCell.minutesLabel.text = String(minutes.displayValue)
                minutesCell.titleLabel.text = minutes.title
                if self.viewModel.isMinutesSelected(at: index) {
                    minutesCell.isSelected = true
                } else {
                    minutesCell.isSelected = false
                }
            }
        }
        
        minutesCollectionView.didSelectIndex = { index in
            if self.viewModel.isMinutesSelected(at: index) {
                let minutes = self.viewModel.selectedNotificationMinutes[index]
                self.viewModel.removeNotification(for: minutes)
                self.minutesCollectionView.reloadData()
                self.reloadSelectedNotifyRow()
            } else {
                self.viewModel.addNotification(for: self.viewModel.selectedNotificationMinutes[index]) {
                    self.minutesCollectionView.reloadData()
                    self.reloadSelectedNotifyRow()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Deselect selected row.
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        highlightCell()
    }
    
    // MARK: - Navigation
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
                self.nextButton.isEnabled = true
                self.setupNextButton()
                self.highlightCell()
                if self.errorView.isDescendant(of: self.view) {
                    self.removeErrorView()
                }
            case .nothing:
                self.nextButton.isEnabled = false
                self.addNothingView()
            case .error:
                self.nextButton.isEnabled = false
                self.addErrorView()
            }
            self.tableView.refreshControl?.endRefreshing()
            self.errorActivityIndicator.stopAnimating()
        }
    }
    
    @objc func didRefresh() {
        viewModel.selectedNotifyIndexPath = nil
        hideMinutesView(true)
        getZmanim()
    }
    
    /// Highlights cell to be highlighted. Usually from notification.
    func highlightCell() {
        if let highlightIndexPath = viewModel.highlightIndexPath {
            tableView.selectRow(at: highlightIndexPath, animated: false, scrollPosition: .middle)
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { timer in
                self.tableView.deselectRow(at: highlightIndexPath, animated: true)
            }
            viewModel.clearHighlight()
        }
    }
    
    func reloadSelectedNotifyRow() {
        if let indexPath = viewModel.selectedNotifyIndexPath {
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func showMinutesView(_ animated: Bool) {
        minutesView.isHidden = false
        isMinutesViewAnimating = true
        UIView.animate(withDuration: animated ? 0.25 : 0, animations: {
            self.tableView.contentInset.bottom = self.minutesView.frame.height + 10 + (self.isiPhoneX ? 0 : 20)
            self.minutesView.transform = .identity
            if let indexPath = self.viewModel.selectedNotifyIndexPath {
                let rectInTableView = self.tableView.rectForRow(at: indexPath)
                let rectInView = self.tableView.convert(rectInTableView, to: self.view)
                let cellBottomY = rectInView.origin.y + rectInView.size.height
                if cellBottomY >= self.minutesView.frame.origin.y {
                    self.contentOffsetBeforeMinutesViewY = self.tableView.contentOffset.y
                    self.tableView.contentOffset.y += (cellBottomY - self.minutesView.frame.origin.y) + 10
                }
            }
        }) { completed in
            self.isMinutesViewAnimating = false
        }
    }
    
    func hideMinutesView(_ animated: Bool) {
        isMinutesViewAnimating = true
        UIView.animate(withDuration: animated ? 0.2 : 0, animations: {
            self.tableView.contentInset.bottom = 0
            self.minutesView.transform = CGAffineTransform(translationX: 0, y: self.minutesView.frame.height + self.view.safeAreaInsets.bottom + (self.isiPhoneX ? 0 : 20))
            if let contentOffsetY = self.contentOffsetBeforeMinutesViewY {
                self.tableView.contentOffset.y = contentOffsetY
            }
        }) { completed in
            self.isMinutesViewAnimating = false
            self.minutesView.isHidden = true
        }
    }
    
    func setupNextButton() {
        if let nextZman = viewModel.nextZman, nextZman.tefillah == viewModel.tefillah {
            nextButton.isEnabled = true
        } else {
            nextButton.isEnabled = false
        }
    }
    
    func addNothingView() {
        view.addSubview(nothingView)
        view.bringSubview(toFront: nothingView)
        NSLayoutConstraint.activate([
            nothingView.leftAnchor.constraint(equalTo: view.leftAnchor),
            nothingView.topAnchor.constraint(equalTo: view.topAnchor),
            nothingView.rightAnchor.constraint(equalTo: view.rightAnchor),
            nothingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func addErrorView() {
        view.addSubview(errorView)
        view.bringSubview(toFront: errorView)
        NSLayoutConstraint.activate([
            errorView.leftAnchor.constraint(equalTo: view.leftAnchor),
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.rightAnchor.constraint(equalTo: view.rightAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
    
    @IBAction func didTapNext(_ sender: UIBarButtonItem) {
        if let nextZmanIndexPath = viewModel.nextZmanIndexPath {
            tableView.scrollToRow(at: nextZmanIndexPath, at: .top, animated: true)
        }
    }
    
    @IBAction func didTapMinuteViewDone(_ sender: UIButton) {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        viewModel.selectedNotifyIndexPath = nil
        hideMinutesView(true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ZmanimViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.zmanCellIdentifier.rawValue) as! ZmanCell
        
        if let selectedNotifyIndexPath = viewModel.selectedNotifyIndexPath {
            if selectedNotifyIndexPath == indexPath {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
        
        if let zman = viewModel.zman(for: indexPath.section) {
            let location = zman.locations[indexPath.row]
            cell.locationLabel.text = location.title
            
            cell.didTapNotify = { cell in
                self.viewModel.canAddNotifications { canAdd in
                    if canAdd {
                        self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                        self.viewModel.selectedNotifyIndexPath = indexPath
                        self.minutesCollectionView.reloadData()
                        self.minutesCollectionView.contentOffset.x = 0
                        self.showMinutesView(true)
                        self.viewModel.log(.didSetNotification, at: indexPath)
                    } else {
                        let alertController = UIAlertController(title: "😬 Oh no!", message: "There seems to be an issue adding an alert. Please check your settings and make sure we're allowed to!", preferredStyle: .alert)
                        let action = UIAlertAction(title: "👍", style: .default) { alert in
                            self.dismiss(animated: true, completion: nil)
                        }
                        alertController.addAction(action)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        
        if viewModel.notificationMinutes(for: indexPath).isEmpty {
            cell.notifyButton.isHidden = true
        } else {
            cell.notifyButton.isHidden = false
            if viewModel.isAnyMinutesSelected(at: indexPath) {
                cell.notifyButton.setTitle("👍", for: .normal)
            } else {
                cell.notifyButton.setTitle("🔔", for: .normal)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.sectionHeaderViewHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let zman = viewModel.zman(for: section) {
            let sectionHeaderView = SectionTitleHeaderView(title: zman.date.shortTimeString)
            if let nextZman = viewModel.nextZman, zman == nextZman, nextZman.date.isToday {
                sectionHeaderView.titleColor = .blueberry
                sectionHeaderView.titleWeight = .bold
                sectionHeaderView.headerLabel.beginBlinking()
            } else {
                sectionHeaderView.titleColor = .black
                sectionHeaderView.titleWeight = .semibold
                sectionHeaderView.headerLabel.endBlinking()
            }
            return sectionHeaderView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hideMinutesView(true)
        if let zman = viewModel.zman(for: indexPath.section) {
            if zman.locations[indexPath.row].recognized {
                performSegue(withIdentifier: SegueIdentifier.showLocation.rawValue, sender: indexPath)
            }
        }
        viewModel.log(.didTapZman, at: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isMinutesViewAnimating {
            // Set to `nil` if content offset changed so doesn't change back and be intrusive.
            contentOffsetBeforeMinutesViewY = nil
        }
    }
}

// MARK: - UIViewControllerPreviewingDelegate
extension ZmanimViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
            if let locationViewController = storyboard?.instantiateViewController(withIdentifier: LocationTableViewController.storyboardID) as? LocationTableViewController, let zman = viewModel.zman(for: indexPath.section) {
                locationViewController.viewModelData = LocationViewModelData(location: zman.locations[indexPath.row])
                return locationViewController
            }
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

private extension UIView {
    func beginBlinking() {
        UIView.animate(withDuration: 1, delay: 1, animations: {
            self.alpha = 0.25
        }) { completed in
            UIView.animate(withDuration: 1, animations: {
                self.alpha = 1
            }) { completed in
                self.beginBlinking()
            }
        }
    }
    
    func endBlinking() {
        alpha = 1
        layer.removeAllAnimations()
    }
}

extension UIColor {
    static let blueberry = UIColor(named: "Blueberry")!
}
