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
    @IBOutlet var nothingView: UIView!
    @IBOutlet var errorView: UIView!
    @IBOutlet var errorTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var errorActivityIndicator: UIActivityIndicatorView!
    
    fileprivate struct Constants {
        static let tableViewRowHeight: CGFloat = 60
        static let sectionHeaderViewHeight: CGFloat = 36
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
        
        registerForPreviewing(with: self, sourceView: tableView)
        
        getZmanim()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Deselect selected row.
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
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
        // Show refresh control.
        // tableView.setContentOffset(CGPoint(x: 0, y: -(tableView.refreshControl?.frame.height ?? 0)), animated: true)
        tableView.refreshControl?.beginRefreshing()
        errorActivityIndicator.startAnimating()
        viewModel.getZmanim { result in
            switch result {
            case .success:
                self.tableView.reloadData()
                if self.errorView.isDescendant(of: self.view) {
                    self.removeErrorView()
                }
            case .nothing:
                self.addNothingView()
            case .error:
                self.addErrorView()
            }
            self.tableView.refreshControl?.endRefreshing()
            self.errorActivityIndicator.stopAnimating()
        }
    }
    
    @objc func didRefresh() {
        getZmanim()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.zmanCellIdentifier.rawValue) as! ZmanTableViewCell
        
        if let zman = viewModel.zman(for: indexPath.section) {
            let location = zman.locations[indexPath.row]
            cell.locationLabel.text = location.title
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.sectionHeaderViewHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let zman = viewModel.zman(for: section) {
            let sectionHeaderView = SectionTitleHeaderView(title: zman.date.shortTimeString)
            if let nextZman = viewModel.nextZman, zman == nextZman {
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
        if let zman = viewModel.zman(for: indexPath.section) {
            if zman.locations[indexPath.row].recognized {
                performSegue(withIdentifier: SegueIdentifier.showLocation.rawValue, sender: indexPath)
            }
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
