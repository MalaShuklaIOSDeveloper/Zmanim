//
//  Selichos.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

//import UIKit
//
//class SelichosTableViewController: UITableViewController, ZmanimDataSourceDelegate {
//    var nightSelichos: [Selichos]! {
//        didSet {
//            tableView.reloadData()
//        }
//    }
//    var daySelichos: [Selichos]! {
//        didSet {
//            tableView.reloadData()
//        }
//    }
//    var showDay = false {
//        didSet {
//            tableView.reloadData()
//            if showDay {
//                nightDayButton.title = Constants.Selichos.Night
//            } else {
//                nightDayButton.title = Constants.Selichos.Day
//            }
//        }
//    }
//    
//    @IBOutlet weak var nightDayButton: UIBarButtonItem!
//    
//    override func viewDidLoad() {
//        ZmanimDataSource.dataSource.delegate = self
//        nightSelichos = ZmanimDataSource.dataSource.nightSelichos
//        daySelichos = ZmanimDataSource.dataSource.daySelichos
//        if nightSelichos == nil || daySelichos == nil {
//            ZmanimDataSource.dataSource.fetchAndConfigureSelichos()
//        }
//    }
//    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return showDay ? daySelichos.count : nightSelichos.count
//    }
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return showDay ? daySelichos[section].times.count : nightSelichos[section].times.count
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let sectionSelichos = showDay ? daySelichos[indexPath.section] : nightSelichos[indexPath.section]
//        let selichosTime = sectionSelichos.times[indexPath.row]
//        
//        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Storyboard.CellReuseIdentifier, for: indexPath)
//        cell.textLabel?.text = selichosTime.title
//        cell.detailTextLabel?.text = selichosTime.time
//        
//        return cell
//    }
//    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return showDay ? daySelichos[section].location.title : nightSelichos[section].location.title
//    }
//    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 52
//    }
//    
//    func handleSelichosFetchCompletion() {
//        nightSelichos = ZmanimDataSource.dataSource.nightSelichos
//        daySelichos = ZmanimDataSource.dataSource.daySelichos
//    }
//    
//    @IBAction func showNightDay(_ sender: UIBarButtonItem) {
//        showDay = !showDay
//    }
//}
