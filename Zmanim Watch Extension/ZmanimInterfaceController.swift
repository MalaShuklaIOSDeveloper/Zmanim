//
//  ZmanimInterfaceController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2016 Natanel Niazoff. All rights reserved.
//

import Foundation
import WatchKit

protocol ZmanimInterfaceControllerContext {
    var tefillah: Tefillah { get }
    var zmanim: [Zman]? { get }
}

private class Context: LocationsInterfaceControllerContext {
    var location: Location!
    
    init(location: Location? = nil) {
        self.location = location
    }
}

class ZmanimInterfaceController: WKInterfaceController {
    // MARK: Properties
    var contextInput: ZmanimInterfaceControllerContext! {
        didSet {
            tefillah = contextInput.tefillah
            zmanim = contextInput.zmanim
        }
    }
    var tefillah: Tefillah!
    var zmanim: [Zman]? {
        didSet {
            if zmanim != nil {
                noZmanimLabel.setHidden(!zmanim!.isEmpty)
                zmanim!.findNextZman(with: Date(), setZmanNext: true)
                loadInterfaceTableData()
            }
        }
    }
    fileprivate var contextOutput = Context()
    
    // MARK: IBOutlets
    @IBOutlet var interfaceTable: WKInterfaceTable!
    @IBOutlet var loadingLabel: WKInterfaceLabel!
    @IBOutlet var noZmanimLabel: WKInterfaceLabel!
    @IBOutlet var errorLabel: WKInterfaceLabel!
    
    // MARK: Lifecycle
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.contextInput = context as! ZmanimInterfaceControllerContext
        
        setTitle(tefillah.title)
        loadInterfaceTableData()
        
        ZmanimDataSource.dataSource.delegate = self
        if zmanim == nil {
            loadingLabel.setHidden(false)
            if !ZmanimDataSource.dataSource.isFetchingZmanim {
                ZmanimDataSource.dataSource.fetchAndConfigureZmanim(for: Date())
            }
        }
    }
    
    // MARK: Overrides
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let zmanimLocations = zmanim![rowIndex].locations
        if zmanimLocations.count > 1 {
            var locationActions = [WKAlertAction]()
            for location in zmanimLocations {
                let locationAction = WKAlertAction(title: location.title!, style: .default) {
                    if location.recognized {
                        self.contextOutput.location = location
                        self.pushController(withName: Constants.Storyboard.Watch.Zmanim.LocationInterfaceControllerIdentifier, context: self.contextOutput)
                    } else {
                        self.presentAlertController(title: Constants.Alerts.UnknownLocation.Title, message: Constants.Alerts.UnknownLocation.Message, withCancelAction: true, cancelActionTitle: Constants.Alerts.Actions.OK) {
                            self.dismiss()
                        }
                    }
                }
                locationActions.append(locationAction)
            }
            presentAlertController(message: Constants.Alerts.Watch.Selection.Message,prefferedStyle: .actionSheet, actions: locationActions, withCancelAction: true) {
                self.dismiss()
            }
        } else {
            if zmanimLocations.first!.recognized {
                contextOutput.location = zmanimLocations.first!
                pushController(withName: Constants.Storyboard.Watch.Zmanim.LocationInterfaceControllerIdentifier, context: contextOutput)
            } else {
                presentAlertController(title: Constants.Alerts.UnknownLocation.Title, message: Constants.Alerts.UnknownLocation.Message, withCancelAction: true, cancelActionTitle: Constants.Alerts.Actions.OK) {
                    self.dismiss()
                }
            }
        }
    }
    
    // MARK: Methods
    func loadInterfaceTableData() {
        interfaceTable.setNumberOfRows((zmanim?.count ?? 0), withRowType: Constants.Storyboard.Watch.Zmanim.TextSubtitleRowControllerIdentifier)
        if zmanim != nil {
            for (index, zman) in zmanim!.enumerated() {
                if let textSubtitleRowController = interfaceTable.rowController(at: index) as? TextSubtitleRowController {
                    textSubtitleRowController.interfaceLabel.setText(zman.date.shortTimeString)
                    if zman.next {
                        textSubtitleRowController.rowGroup.setBackgroundColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 1))
                        textSubtitleRowController.interfaceLabel.setTextColor(UIColor.white)
                        textSubtitleRowController.subtitleInterfaceLabel.setTextColor(UIColor.white)
                    }
                    
                    var locationsSubtitleText = zman.locations[0].title!
                    if zman.locations.count == 2 {
                        locationsSubtitleText += " & \(zman.locations[1].title!)"
                    } else if zman.locations.count > 2 {
                        locationsSubtitleText += " & \(zman.locations.count - 1) More"
                    }
                    textSubtitleRowController.subtitleInterfaceLabel.setText(locationsSubtitleText)
                }
            }
        }
    }
    
    func refresh() {
        loadingLabel.setHidden(false)
        noZmanimLabel.setHidden(true)
        errorLabel.setHidden(true)
        ZmanimDataSource.dataSource.fetchAndConfigureZmanim(for: Date())
    }
    
    // MARK: IBActions
    @IBAction func refreshTapped() {
        refresh()
    }
}

extension ZmanimInterfaceController: ZmanimDataSourceDelegate {
    func handleZmanimFetchCompletion() {
        loadingLabel.setHidden(true)
        noZmanimLabel.setHidden(true)
        errorLabel.setHidden(true)
        zmanim = ZmanimDataSource.dataSource.zmanimForTefillah(tefillah)
    }
    
    func handleZmanimFetchError(_ error: Error) {
        loadingLabel.setHidden(true)
        noZmanimLabel.setHidden(true)
        errorLabel.setHidden(false)
    }
}
