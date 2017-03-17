//
//  Main.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import UIKit
import SafariServices
import DatePickerDialog

class MainTableViewController: UITableViewController, ZmanimTableViewControllerDataSource {
    fileprivate class Cell {
        var viewController: MainTableViewController?
        let tefillah: Tefillah?
        let title: String?
        let segueIdentifier: String?
        let selectionHandler: ((Cell) -> Void)?
        let seguePreperationHandler: ((UIStoryboardSegue, AnyObject?) -> Void)?
        
        var cellTextColor: UIColor {
            if tefillah != nil {
                if tefillah == .maariv && viewController?.date.weekday == 6 {
                    return UIColor.lightGray
                } else if viewController?.date.weekday == 7 {
                    return UIColor.lightGray
                }
            }
            return UIColor.black
        }
        
        init(viewController: MainTableViewController, tefillah: Tefillah? = nil, title: String? = nil, segueIdentifier: String? = nil, selectionHandler: ((Cell) -> Void)? = nil, seguePreperationHandler: ((UIStoryboardSegue, AnyObject?) -> Void)? = nil) {
            self.viewController = viewController
            self.tefillah = tefillah
            self.title = (tefillah != nil && title == nil) ? tefillah!.title : title
            self.segueIdentifier = segueIdentifier
            self.selectionHandler = selectionHandler
            self.seguePreperationHandler = seguePreperationHandler
        }
    }
    fileprivate class Action: UIAlertAction {
        var titleHandler: ((Void) -> String?)?
        
        override var title: String? {
            return titleHandler != nil ? titleHandler!() : super.title
        }
    }
    
    // MARK: Properties
    var zmanim: [Zman]? {
        didSet {
            nextZman = viewModel?.findNextZman()
        }
    }
    var date: Date {
        get {
            return ZmanimDataSource.dataSource.date
        }
        set {
            ZmanimDataSource.dataSource.date = newValue
            ZmanimDataSource.dataSource.fetchAndConfigureZmanim(for: date)
            setDateButtonText()
            tableView.reloadData()
        }
    }
    fileprivate var nextZman: Zman? {
        willSet {
            if newValue != nextZman && newValue != nil {
                if !headerView.isDescendant(of: view) {
                   tableView.setup(headerView!, with: Constants.Main.TableViewHeaderViewHeight, in: self, animated: true)
                }
                nextZmanLabel.text = "\(newValue!.tefillah.title) at \(newValue!.date.shortTimeString) in \(newValue!.locations.first!.title!)"
                locationImageView.setup(with: newValue!.locations.first!, animated: true)
            } else {
                if newValue == nil {
                    tableView.remove(headerView, in: self, animated: true)
                }
            }
        }
    }
    fileprivate var viewModel: ZmanimViewModel!
    fileprivate var cells = [Cell]()
    fileprivate var headerView: UIView! {
        didSet {
            if nextZman != nil {
                tableView.setup(headerView!, with: Constants.Main.TableViewHeaderViewHeight, in: self, animated: true)
                // TODO: set next zman
            }
        }
    }
    fileprivate lazy var tefillahSelectionHandler: (Cell) -> Void = { cell in
        let presentShabbosAlertController = {
            self.presentAlertController(
                title: Constants.Alerts.Main.Shabbos.Title,
                message: Constants.Alerts.Main.Shabbos.Message,
                withCancelAction: true,
                cancelActionTitle: Constants.Alerts.Actions.OK,
                cancelActionHandler: { action, viewController in
                    self.deselectSelectedRow()
                    viewController?.dismiss(animated: true, completion: nil)
            })
        }
        if cell.tefillah == .maariv && self.date.weekday == 6 {
            presentShabbosAlertController()
        } else if self.date.weekday == 7 {
            presentShabbosAlertController()
        } else {
            self.performSegue(withIdentifier: cell.segueIdentifier!, sender: cell)
        }
    }
    fileprivate lazy var tefillahSeguePreperationHandler: (UIStoryboardSegue, AnyObject?) -> Void = { segue, sender in
        let cell = sender as! Cell
        let zmanimTableViewController = segue.destination as! ZmanimTableViewController
        zmanimTableViewController.tefillah = cell.tefillah!
        zmanimTableViewController.zmanim = ZmanimDataSource.dataSource.zmanimForTefillah(cell.tefillah!)
    }
    fileprivate lazy var selichosSelectionHandler: (Cell) -> Void = { cell in
        self.performSegue(withIdentifier: cell.segueIdentifier!, sender: cell)
    }
    fileprivate var shabbosTitle: String {
        if let shabbos = ZmanimDataSource.dataSource.shabbos {
            return ("\(Constants.Alerts.Main.MoreOptions.Shabbos) \(shabbos.parsha)")
        }
        return Constants.Alerts.Main.MoreOptions.Shabbos
    }
    
    //fileprivate let oneStopAdButtonView = AdButtonView(image: UIImage(named: Constants.Assets.Images.OneStopBanner)!)
    
    var viewDidAppearHasRun = false
    
    // MARK: IBOutlets
    @IBOutlet weak var nextZmanLabel: UILabel!
    @IBOutlet weak var mapButton: UIBarButtonItem!
    @IBOutlet weak var dateButton: UIBarButtonItem! {
        didSet {
            setDateButtonText()
        }
    }
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationImageViewActivityIndicator: UIActivityIndicatorView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = Constants.Main.TableViewRowHeight
        clearsSelectionOnViewWillAppear = true
        automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        let titleIconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        titleIconImageView.image = UIImage(named: Constants.Assets.Images.TitleIcon)!
        titleIconImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleIconImageView
        
        viewModel = ZmanimViewModel(dataSource: self)
        headerView = tableView.tableHeaderView!
        tableView.tableHeaderView = nil
        
        func tefillahCellForTefillah(_ tefillah: Tefillah) -> Cell {
            return Cell(viewController: self, tefillah: tefillah,
                segueIdentifier: Constants.Storyboard.Main.ShowZmanimSegueIdentifier,
                selectionHandler: tefillahSelectionHandler,
                seguePreperationHandler: tefillahSeguePreperationHandler)
        }
        cells = [
            tefillahCellForTefillah(.shacharis),
            tefillahCellForTefillah(.mincha),
            tefillahCellForTefillah(.maariv),
            Cell(viewController: self, title: Constants.Main.More, selectionHandler: { cell in
                let actions = [
                    Action(title: self.shabbosTitle, style: .default) { action in
                        self.presentShabbosPDF()
                    },
                    Action(title: Constants.Alerts.Main.MoreOptions.LocalZmanim, style: .default) { action in
                        self.performSegue(withIdentifier: Constants.Storyboard.Main.ShowLocalZmanimSegueIdentifier, sender: nil)
                    },
                    Action(title: Constants.Alerts.Main.MoreOptions.About, style: .default) { action in
                        self.performSegue(withIdentifier: Constants.Storyboard.Main.ShowAboutSegueIdentifier, sender: nil)
                    },
                    Action(title: Constants.Alerts.Main.MoreOptions.Sponsor, style: .default) { action in
                        self.openMail()
                    }
                ]
                self.presentAlertController(
                    preferredStyle: .actionSheet,
                    actions: actions,
                    withCancelAction: true,
                    cancelActionHandler: { action in
                        self.dismiss(animated: true, completion: nil)
                        self.deselectSelectedRow()
                    })
            })
        ]
        
        
        // Prepares the data source
        ZmanimDataSource.dataSource.delegate = self
        ZmanimDataSource.dataSource.fetchAndConfigureZmanim(for: date)
        ZmanimDataSource.dataSource.fetchAndConfigureShabbos(delegateCompletion: false, delegateError: false)
        
        locationImageViewActivityIndicator.startAnimating()
        
//        navigationController?.view.addSubview(oneStopAdButtonView)
//        
//        let oneStopAdButtonViewTargets = [
//            Target(target: self, action: #selector(MainTableViewController.presentAd(_:)), controlEvents: .touchUpInside),
//            Target(target: self, action: #selector(MainTableViewController.selectAd(_:)), controlEvents: .touchDown),
//            Target(target: self, action: #selector(MainTableViewController.deselectAd(_:)), controlEvents: .touchDragExit)
//        ]
//        oneStopAdButtonView.addTargets(oneStopAdButtonViewTargets)
        
        tableView.contentInset.bottom = 60
        tableView.scrollIndicatorInsets.bottom = 60
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Sets the data source delegate to self everytime view appears
        // TODO: put here everywhere
        ZmanimDataSource.dataSource.delegate = self
        
        // When returning to table view selected row is deselected
        deselectSelectedRow()
        
        setDateButtonText()
        //oneStopAdButtonView.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if viewDidAppearHasRun {
            zmanim = ZmanimDataSource.dataSource.zmanim
        }
        
        viewDidAppearHasRun = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //oneStopAdButtonView.isHidden = true
    }
    
    // MARK: Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Storyboard.CellReuseIdentifier)!
        cell.textLabel?.text = cells[indexPath.row].title
        cell.textLabel?.textColor = cells[indexPath.row].cellTextColor
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = cells[indexPath.row]
        if let cellSelectionHandler = cell.selectionHandler {
            cellSelectionHandler(cell)
        } else if let cellSegueIdentifier = cell.segueIdentifier {
            performSegue(withIdentifier: cellSegueIdentifier, sender: cell)
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? Cell {
            if let cellSeguePreperationHandler = cell.seguePreperationHandler {
                cellSeguePreperationHandler(segue, sender as AnyObject?)
            }
        }
        if let barButtonItem = sender as? UIBarButtonItem {
            // TODO: change
            if barButtonItem == mapButton {
                segue.destination.transitioningDelegate = self
            }
        }
    }
    
    // MARK: Methods
    func setDateButtonText() {
        dateButton.title = date.isToday ? "Today, \(date.shortTimeString)" : date.shortDateTimeString
    }
    
    func deselectSelectedRow() {
        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRowIndexPath, animated: true)
        }
    }
    
    func presentShabbosPDF() {
        if let shabbos = ZmanimDataSource.dataSource.shabbos {
            shabbos.url.loadInSafariViewController(in: self)
        } else {
            ZmanimDataSource.dataSource.fetchAndConfigureShabbos()
        }
    }
    
    func openMail() {
        URL.open(Constants.URLs.EmailMe)
    }
    
    func presentAd(_ sender: AnyObject) {
        if let button = sender as? UIButton {
            button.imageView?.alpha = 1
        }
        let url = Foundation.URL(string: "https://www.facebook.com/onestopkosher")!
        url.loadInSafariViewController(in: self)
    }
    
    func selectAd(_ sender: AnyObject) {
        if let button = sender as? UIButton {
            button.imageView?.alpha = 0.8
        }
    }
    
    func deselectAd(_ sender: AnyObject) {
        if let button = sender as? UIButton {
            button.imageView?.alpha = 1
        }
    }
    
    // MARK: IBActions
    @IBAction func presentMap(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Constants.Storyboard.Main.PresentMapSegueIdentifier, sender: sender)
    }
    @IBAction func changeDate(_ sender: UIBarButtonItem) {
        DatePickerDialog().show(title: "Choose a date...", defaultDate: date, minimumDate: Date().isPastMidnightBeforeTwo ? Date().yesterday : Date(), maximumDate: Date().addingWeek(), datePickerMode: .dateAndTime) { date in
            self.date = date ?? self.date
        }
    }
    
    // MARK: Scroll View Delegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if headerView != nil {
            tableView.update(headerView!, with: Constants.Main.TableViewHeaderViewHeight)
        }
    }
}

extension MainTableViewController: ZmanimDataSourceDelegate {
    func handleZmanimFetchCompletion() {
        locationImageViewActivityIndicator.stopAnimating()
        zmanim = ZmanimDataSource.dataSource.zmanim
    }
    
    func handleZmanimFetchError(_ error: NSError) {
        locationImageViewActivityIndicator.stopAnimating()
        tableView.remove(headerView, in: self)
    }
    
    func handleShabbosFetchCompletion() {
        presentShabbosPDF()
    }
    
    func handleShabbosFetchError(_ error: NSError) {
        dismiss(animated: true, completion: nil)
        switch error.code {
        case Constants.ErrorCodes.NoNetwork:
            presentAlertController(
                title: Constants.Alerts.Error.Network.Title,
                message: Constants.Alerts.Error.Network.Message,
                preferredStyle: .alert,
                withCancelAction: true,
                cancelActionTitle: Constants.Alerts.Actions.OK)
        default:
            presentAlertController(
                title: Constants.Alerts.Error.Title,
                message: Constants.Alerts.Error.Message,
                preferredStyle: .alert,
                withCancelAction: true,
                cancelActionTitle: Constants.Alerts.Actions.OK)
        }
    }
    func handleSelichosFetchCompletion() {
        if let nightSelichos = ZmanimDataSource.dataSource.nightSelichos, let daySelichos = ZmanimDataSource.dataSource.daySelichos {
            if !nightSelichos.isEmpty && !daySelichos.isEmpty {
                cells.insert(Cell(viewController: self, title: Constants.Main.Selichos, segueIdentifier: Constants.Storyboard.Main.ShowSelichosSegueIdentifier, selectionHandler: selichosSelectionHandler), at: 3)
                let range = NSMakeRange(0, tableView.numberOfSections)
                let indexSet = IndexSet(integersIn: range.toRange() ?? 0..<0)
                tableView.reloadSections(indexSet, with: .automatic)
            }
        }
    }
}

extension MainTableViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimatedController(duration: Constants.Main.MapLaunchTransitionDuration)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimatedController(type: .slideDown, duration: Constants.Main.MapDismissTransitionDuration)
    }
}
