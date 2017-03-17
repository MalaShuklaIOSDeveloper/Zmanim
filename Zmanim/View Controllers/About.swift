//
//  About.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
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
    
    init(title: String? = nil, cell: UITableViewCell, height: CGFloat = Constants.About.DefaultCellHeight, selectionHandler: ((Cell) -> Void)? = nil) {
        self.title = title
        self.cell = cell
        self.height = height
        self.selectionHandler = selectionHandler
    }
}

class AboutTableViewController: UITableViewController {
    // MARK: Properties
    fileprivate var sections = [Section]()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = Constants.About.Title
        
        func buttonCellWithTitle(_ title: String) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Storyboard.About.ButtonCellIdentifier)!
            cell.textLabel?.text = title
            cell.textLabel?.textColor = view.tintColor
            return cell
        }
        
        let versionCell = tableView.dequeueReusableCell(withIdentifier: Constants.Storyboard.About.TextCellIdentifier)!
        versionCell.isUserInteractionEnabled = false
        versionCell.textLabel?.text = Constants.About.Version + " " + (Bundle.main.object(forInfoDictionaryKey: Constants.About.VerisonInfoDictionaryKey) as! String)
        
        sections = [
            Section(cells: [
                Cell(cell: tableView.dequeueReusableCell(withIdentifier: Constants.Storyboard.About.ImageCellIdentifier)!, height: Constants.About.ImageCellHeight)
            ]),
            Section(cells: [
                Cell(cell: versionCell)
            ]),
            Section(cells: [
                Cell(cell: buttonCellWithTitle(Constants.About.Website), selectionHandler: { cell in
                    self.presentOrOpenWebsiteURL()
                }),
                Cell(cell: buttonCellWithTitle(Constants.About.ContactUs), selectionHandler: { cell in
                    self.openMail()
                }),
                Cell(cell: buttonCellWithTitle(Constants.About.RateUs), selectionHandler: { cell in
                    self.openAppStore()
                })
            ])
        ]
        
        // Sets copyright label to footer
        let footerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: Constants.About.FooterHeight))
        footerLabel.text = Constants.About.Footer
        footerLabel.font = UIFont.systemFont(ofSize: Constants.About.FooterTextSize)
        footerLabel.textColor = UIColor.gray
        footerLabel.textAlignment = .center
        footerLabel.numberOfLines = 0
        tableView.tableFooterView = footerLabel
    }
    
    // MARK: Table View Data Source
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
    
    // MARK: Methods
    // TODO: make functions
    func presentOrOpenWebsiteURL() {
        if let websiteURL = URL(string: Constants.URLs.ZmanimWebsite) {
            let websiteSafariViewController = SFSafariViewController(url: websiteURL)
            let navigationViewController = UINavigationController(rootViewController: websiteSafariViewController)
            navigationViewController.setNavigationBarHidden(true, animated: false)
            present(navigationViewController, animated: true, completion: nil)
        }
    }
    
    func openMail() {
        URL.open(Constants.URLs.EmailMe)
    }
    
    func openAppStore() {
        URL.open(Constants.URLs.ZmanimAppStore)
    }
}
