//
//  AboutViewController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import SafariServices

fileprivate struct Section {
    let title: String?
    let cells: [Cell]
    
    init(title: String? = nil, cells: [Cell]) {
        self.title = title
        self.cells = cells
    }
}

fileprivate struct Cell {
    let title: String?
    let cell: UITableViewCell
    let height: CGFloat
    let selectionHandler: ((Cell) -> Void)?
    
    fileprivate struct Constants {
        static let rowHeight: CGFloat = 60
    }
    
    init(title: String? = nil, cell: UITableViewCell, height: CGFloat = Constants.rowHeight, selectionHandler: ((Cell) -> Void)? = nil) {
        self.title = title
        self.cell = cell
        self.height = height
        self.selectionHandler = selectionHandler
    }
}

class AboutTableViewController: UITableViewController {
    private var sections = [Section]()
    
    var currentYear: String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
    
    private struct Constants {
        static let emailWithHello = "mailto:nniazoff@zmanimapp.com?subject=Hello!"
        static let zmanimAppStore = "itms-apps://itunes.apple.com/app/id1071006216"
    }
    
    enum CellIdentifier: String {
        case imageCell, textCell, buttonCell, descriptionCell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = Cell.Constants.rowHeight
        
        func buttonCellWithTitle(_ title: String) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.buttonCell.rawValue)!
            cell.textLabel?.text = title
            cell.textLabel?.textColor = view.tintColor
            return cell
        }
        
        let versionCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.textCell.rawValue)!
        versionCell.isUserInteractionEnabled = false
        versionCell.textLabel?.text = "Version" + " " + (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
        
        let creditsCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.descriptionCell.rawValue) as! DescriptionCell
        creditsCell.isUserInteractionEnabled = false
        creditsCell.descriptionLabel.text = "YUZmanim.com\nAaron Shakib\nACM at Yeshiva University"
        
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
            ]),
            Section(title: "CREDITS", cells: [
                Cell(cell: creditsCell, height: UITableViewAutomaticDimension)
            ])
        ]
        
        let footerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
        footerLabel.text = "Copyright © \(currentYear) Natanel Niazoff.\nAll rights reserved."
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
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
