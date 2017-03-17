//
//  MainInterfaceController.swift
//  Zmanim Watch Extension
//
//  Created by Natanel Niazoff.
//  Copyright © 2016 Natanel Niazoff. All rights reserved.
//

import Foundation
import WatchKit

private class Cell {
    let tefillah: Tefillah?
    let title: String?
    let selectionHandler: ((Cell) -> Void)?
    
    init(tefillah: Tefillah? = nil, title: String? = nil, selectionHandler: ((Cell) -> Void)? = nil) {
        self.tefillah = tefillah
        self.title = (tefillah != nil && title == nil) ? tefillah!.title : title
        self.selectionHandler = selectionHandler
    }
}

private class Context: ZmanimInterfaceControllerContext {
    let tefillah: Tefillah
    let zmanim: [Zman]?
    
    init(tefillah: Tefillah, zmanim: [Zman]?) {
        self.tefillah = tefillah
        self.zmanim = zmanim
    }
}

class MainInterfaceController: WKInterfaceController {
    // MARK: Properties
    fileprivate var cells = [Cell]()
    fileprivate lazy var tefillahSelectionHandler: (Cell) -> Void = { cell in
        if cell.tefillah == .maariv && Date().weekday == 6 {
            self.presentAlertController(title: Constants.Alerts.Watch.Shabbos.Title, message: Constants.Alerts.Watch.Shabbos.Message, withCancelAction: true, cancelActionTitle: Constants.Alerts.Actions.OK)
        } else if Date().weekday == 7 {
            self.presentAlertController(title: Constants.Alerts.Watch.Shabbos.Title, message: Constants.Alerts.Watch.Shabbos.Message, withCancelAction: true, cancelActionTitle: Constants.Alerts.Actions.OK)
        } else {
            let context = Context(tefillah: cell.tefillah!, zmanim: ZmanimDataSource.dataSource.zmanimForTefillah(cell.tefillah!))
            self.pushController(withName: Constants.Storyboard.Watch.Main.ZmanimInterfaceController, context: context)
        }
    }
    
    // MARK: IBOutlets
    @IBOutlet var interfaceTable: WKInterfaceTable!
    
    // MARK: Lifecycle
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        setTitle(Constants.Watch.Main.Title)
        
        func tefillahCellForTefillah(_ tefillah: Tefillah) -> Cell {
            return Cell(tefillah: tefillah, selectionHandler: tefillahSelectionHandler)
        }
        cells = [
            tefillahCellForTefillah(.shacharis),
            tefillahCellForTefillah(.mincha),
            tefillahCellForTefillah(.maariv)
        ]
        loadInterfaceTableData()
        
        ZmanimDataSource.dataSource.delegate = self
        ZmanimDataSource.dataSource.fetchAndConfigureZmanim(for: Date())
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        cells[rowIndex].selectionHandler?(cells[rowIndex])
    }
    
    // MARK: Methods
    func loadInterfaceTableData() {
        interfaceTable.setNumberOfRows(cells.count, withRowType: Constants.Storyboard.Watch.Main.TextRowControllerIdentifier)
        for (index, cell) in cells.enumerated() {
            if let textRowController = interfaceTable.rowController(at: index) as? TextRowController {
                textRowController.interfaceLabel.setText(cell.title)
            }
        }
    }
}

extension MainInterfaceController: ZmanimDataSourceDelegate {
    func handleZmanimFetchCompletion() {}
    func handleZmanimFetchError(_ error: Error) {}
}
