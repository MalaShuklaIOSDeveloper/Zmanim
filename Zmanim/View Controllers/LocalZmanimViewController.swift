//
//  LocalZmanimViewController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class LocalZmanimViewController: UIViewController {
    fileprivate let viewModel = LocalZmanimViewModel()
    
    //MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var errorView: UIView!
    @IBOutlet var errorActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var errorTapGestureRecognizer: UITapGestureRecognizer!
    
    fileprivate struct Constants {
        static let tableViewRowHeight: CGFloat = 60
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didRefresh), for: .valueChanged)
        errorView.translatesAutoresizingMaskIntoConstraints = false
        
        getLocalZmanim()
    }
    
    func getLocalZmanim() {
        tableView.refreshControl?.beginRefreshing()
        errorActivityIndicator.startAnimating()
        viewModel.getLocalZmanim { result in
            switch result {
            case .success:
                self.tableView.reloadData()
                if self.errorView.isDescendant(of: self.view) {
                    self.removeErrorView()
                }
            case .error:
                self.addErrorView()
            }
            self.tableView.refreshControl?.endRefreshing()
            self.errorActivityIndicator.stopAnimating()
        }
    }
    
    func didRefresh() {
        getLocalZmanim()
    }
    
    func addErrorView() {
        view.addSubview(errorView)
        view.bringSubview(toFront: errorView)
        errorView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        errorView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        errorView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        view.addGestureRecognizer(errorTapGestureRecognizer)
    }
    
    func removeErrorView() {
        errorView.removeFromSuperview()
        view.removeGestureRecognizer(errorTapGestureRecognizer)
    }
    
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        didRefresh()
    }
}

extension LocalZmanimViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let localZman = viewModel.localZman(for: indexPath.row)!
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.localZmanCellIdentifier.rawValue, for: indexPath)
        cell.textLabel?.text = localZman.title
        cell.detailTextLabel?.text = localZman.date.timeWithSecondsString
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.tableViewRowHeight
    }
}
