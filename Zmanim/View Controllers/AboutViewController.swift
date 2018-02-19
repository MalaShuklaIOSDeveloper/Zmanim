//
//  AboutViewController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import SafariServices

private class Section {
    let title: String?
    let cells: [Cell]
    
    init(title: String? = nil, cells: [Cell]) {
        self.title = title
        self.cells = cells
    }
}
private class Cell {
    let title: String?
    let cell: UITableViewCell
    let height: CGFloat
    let selectionHandler: ((Cell) -> Void)?
    
    init(title: String? = nil, cell: UITableViewCell, height: CGFloat = 44, selectionHandler: ((Cell) -> Void)? = nil) {
        self.title = title
        self.cell = cell
        self.height = height
        self.selectionHandler = selectionHandler
    }
}

class AboutTableViewController: UITableViewController {
    fileprivate var sections = [Section]()
    
    var currentYear: String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
    
    struct Constants {
        static let emailWithHello = "mailto:nniazoff@zmanimapp.com?subject=Hello!"
        static let zmanimAppStore = "itms-apps://itunes.apple.com/app/id1071006216"
    }
    
    enum CellIdentifier: String {
        case imageCell, textCell, buttonCell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func buttonCellWithTitle(_ title: String) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.buttonCell.rawValue)!
            cell.textLabel?.text = title
            cell.textLabel?.textColor = view.tintColor
            return cell
        }
        
        let versionCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.textCell.rawValue)!
        versionCell.isUserInteractionEnabled = false
        versionCell.textLabel?.text = "Version" + " " + (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
        
        sections = [
            Section(cells: [
                Cell(cell: tableView.dequeueReusableCell(withIdentifier: CellIdentifier.imageCell.rawValue)!, height: 140)
            ]),
            Section(cells: [
                Cell(cell: versionCell)
            ]),
            Section(cells: [
                Cell(cell: buttonCellWithTitle("Contact Developer"), selectionHandler: { cell in
                    self.openMail()
                }),
                Cell(cell: buttonCellWithTitle("Rate on App Store"), selectionHandler: { cell in
                    self.openAppStore()
                })
            ])
        ]
        
        let footerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
        footerLabel.text = "Copyright © \(currentYear) Natanel Niazoff.\n All rights reserved."
        footerLabel.font = UIFont.systemFont(ofSize: 15)
        footerLabel.textColor = UIColor.gray
        footerLabel.textAlignment = .center
        footerLabel.numberOfLines = 0
        tableView.tableFooterView = footerLabel
    }
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sections[indexPath.section].cells[indexPath.row].cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = sections[indexPath.section].cells[indexPath.row]
        cell.selectionHandler?(cell)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[indexPath.section].cells[indexPath.row].height
    }
    // MARK: -
    
    func openMail() {
        URL.open(Constants.emailWithHello)
    }
    
    func openAppStore() {
        URL.open(Constants.zmanimAppStore)
    }
}
