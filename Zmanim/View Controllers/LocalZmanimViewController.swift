//
//  LocalZmanimViewController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class LocalZmanimTableViewController: UITableViewController {
    var viewModel: LocalZmanimViewModel!
    
    //MARK: - IBOutlets
    @IBOutlet weak var headerLabel: UILabel! {
        didSet {
            headerLabel.text = "Washington Heights"
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = ""
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(didRefresh), for: .valueChanged)
    }
    
    // MARK: - Table View
//    override func numberOfSections(in tableView: UITableView) -> Int {
//
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//    }
    // MARK: -
    
    func didRefresh() {
        
    }
}
