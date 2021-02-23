

import UIKit
import SwiftUI

class ScheduleCalendarViewController: UIViewController, UIScrollViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    // MARK: Controllers
    
    weak var modelController: ScheduleModelController!
    private let searchController = UISearchController()
    lazy private var currentCalendarVC =  SingleCalendarViewController(
        of: currentCalendarView,
        on: today.toInt / 100,
        modelController: modelController, segue: performSegue)
    lazy private var prevCalendarVC = SingleCalendarViewController(
        of: prevCalendarView,
        on: (today.aMonthAgo.toInt / 100),
        modelController: modelController)
    lazy private var nextCalendarVC =
        SingleCalendarViewController(
            of: nextCalendarView,
            on:(today.aMonthAgo.toInt / 100),
            modelController: modelController)
    
    // MARK:- Properties
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var nextCalendarView: UICollectionView!
    @IBOutlet weak var currentCalendarView: UICollectionView!
    @IBOutlet weak var prevCalendarView: UICollectionView!
    @IBOutlet weak var scrollCalendarView: UIScrollView!
    @IBOutlet weak var datePickerModal: UIView!
    
    // MARK:- User intents
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ShowDailyView",
//           let dailyVC = segue.destination as? DailyViewController,
//           let dateToShow = sender as? Int{
//            dailyVC.dateIntShowing = dateToShow
//            dailyVC.modelController = modelController
//        }
//    }
    @IBAction func tapSearchButton(_ sender: Any) {
        if  navigationItem.searchController == nil {
            navigationItem.searchController = searchController
        }else if !navigationItem.searchController!.isEditing {
            navigationItem.searchController = nil
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let searchText = searchBar.text == nil || searchBar.text!.isEmpty ? nil : searchBar.text!
        let priority = searchBar.selectedScopeButtonIndex == 0 ? nil : searchBar.selectedScopeButtonIndex
        currentCalendarVC.searchRequest.text = searchText?.lowercased()
        currentCalendarVC.searchRequest.priority = priority
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > 30 && scrollView.contentOffset.x < 780 {
            return
        }
        let firstDate = scrollView.contentOffset.x < 30 ?  Calendar.firstDateOfMonth(prevCalendarVC.yearAndMonth) :
            Calendar.firstDateOfMonth(nextCalendarVC.yearAndMonth)

        currentCalendarVC.yearAndMonth = (firstDate.year * 100) + firstDate.month
        prevCalendarVC.yearAndMonth = (firstDate.aMonthAgo.year * 100) + firstDate.aMonthAgo.month
        nextCalendarVC.yearAndMonth = (firstDate.aMonthAfter.year * 100) + firstDate.aMonthAfter.month
        updateLabel(with: firstDate)
        scrollView.scrollToChild(currentCalendarView)
    }
    
    private var datePicker = UIDatePicker()
    private(set) var selectedDate = Date()
    @IBAction func showDatePicker(_ sender: UIButton) {
        if datePickerModal.isHidden {
            self.datePickerModal.isHidden = false
            let blurView = UIVisualEffectView(effect:
                                                UIBlurEffect(style: .light))
            blurView.frame = view.bounds
            blurView.alpha = 0.5
            blurView.addGestureRecognizer(
                UITapGestureRecognizer(target: self,
                                       action: #selector(hideDatePicker)))
            view.insertSubview(blurView, belowSubview: datePickerModal)
        }
    }
    
    @objc private func hideDatePicker() {
        let blurView = view.subviews.first() { $0 is UIVisualEffectView }
        blurView?.removeFromSuperview()
        datePickerModal.isHidden = true
    }
    @objc private func selectDateInDatePicker(_ sender: UIDatePicker) {
        deliverDate(sender.date)
        hideDatePicker()
    }
    
    @objc private func deliverDate(_ dateToDeliver: Date) {
        currentCalendarVC.yearAndMonth = (dateToDeliver.year * 100) + dateToDeliver.month
        prevCalendarVC.yearAndMonth = (dateToDeliver.aMonthAgo.year * 100) + dateToDeliver.aMonthAgo.month
        nextCalendarVC.yearAndMonth = (dateToDeliver.aMonthAfter.year * 100) + dateToDeliver.aMonthAfter.month
        updateLabel(with: dateToDeliver)
    }
    
    private func updateLabel(with date: Date)  {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM YYYY"
        monthLabel.text = formatter.string(from: date)
    }
    
    // MARK:- Init
    
    private let today = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        overrideUserInterfaceStyle = .light
        scrollCalendarView.delegate = self
        updateLabel(with: today)
        initDatePicker()
        initNavgationBar()
        if modelController.notificationContoller.authorizationStatus == .notDetermined {
            modelController.notificationContoller.requestPermission()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        scrollCalendarView.scrollToChild(currentCalendarView)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        deliverDate(Date())
    }
    // MARK: Date picker
    
    private func initDatePicker() {
        datePickerModal.layer.borderWidth = 2
        datePickerModal.layer.borderColor = CGColor.salmon 
        datePickerModal.layer.cornerRadius = 10
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePickerModal.addSubview(datePicker)
        datePicker.addTarget(self, action: #selector(selectDateInDatePicker(_:)), for: .valueChanged)
    }
    // MARK: Navigation controller
    
    private func initNavgationBar() {
        let newBackButton = UIBarButtonItem(title: "Back",
                                            style: .plain,
                                            target: self, action: #selector(tapBackButton))
        navigationItem.leftBarButtonItem = newBackButton
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = .search
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = ["All"] +  Color.Button.allCases.map { $0.rawValue }
        searchController.searchBar.delegate = self
    }
    @objc private func tapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    // MARK:- Search controller delegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        navigationItem.searchController!.isEditing = true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        navigationItem.searchController!.isEditing = false
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationItem.searchController!.isEditing = false
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        navigationItem.searchController!.isEditing = false
    }
}
