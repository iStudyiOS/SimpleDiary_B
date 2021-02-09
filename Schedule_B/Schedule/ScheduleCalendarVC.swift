

import UIKit

class ScheduleCalendarViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: -Outlet
   
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var nextCalendarView: UICollectionView!
    @IBOutlet weak var currentCalendarView: UICollectionView!
    @IBOutlet weak var prevCalendarView: UICollectionView!
    @IBOutlet weak var scrollCalendarView: UIScrollView!
    @IBOutlet weak var datePickerModal: UIView!
    
    @IBAction func tapSearchButton(_ sender: Any) {
        
    }
    
    // MARK: -Scroll View
    
    private var currentCalendarVC = SingleCalendarViewController()
    private var prevCalendarVC = SingleCalendarViewController()
    private var nextCalendarVC = SingleCalendarViewController()
    
    
    // MARK: -User intents
    
    // MARK: Tap calendar cell
    @objc private func tapCalenderCell(sender: UITapGestureRecognizer) {
        let cell = sender.view as! CalendarCellVC
        // Todo: Show daily view
        let date = cell.hostingController.rootView.date
        if date != nil {
            print("\(date!) is selected")
        }
    }
    // MARK: Scroll calendar
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > 30 && scrollView.contentOffset.x < 780 {
            return
        }
        let firstDate = scrollView.contentOffset.x < 30 ?  Calendar.firstDateOfMonth(prevCalendarVC.monthAndYear) :
            Calendar.firstDateOfMonth(nextCalendarVC.monthAndYear) 
        
        let aMonthAgo = Date.aMonthAgo(from: firstDate)
        let aMonthAfter = Date.aMonthAfter(from: firstDate)
        
        currentCalendarVC.monthAndYear = (firstDate.year * 100) + firstDate.month
        prevCalendarVC.monthAndYear = (aMonthAgo.year * 100) + aMonthAgo.month
        nextCalendarVC.monthAndYear = (aMonthAfter.year * 100) + aMonthAfter.month
        updateLabel(with: firstDate)
        scrollView.scrollToChild(currentCalendarView)
    }
    
    // MARK: -Date picker
    
    private var datePicker = UIDatePicker()
    private(set) var selectedDate = Date()
    @IBAction func showDatePicker(_ sender: UIButton) {
        if datePickerModal.isHidden {
            self.datePickerModal.isHidden = false
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
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
        currentCalendarVC.monthAndYear = (dateToDeliver.year * 100) + dateToDeliver.month
        let aMonthAgo = Date.aMonthAgo(from: dateToDeliver)
        prevCalendarVC.monthAndYear = (aMonthAgo.year * 100) + aMonthAgo.month
        let aMonthAfter = Date.aMonthAfter(from: dateToDeliver)
        nextCalendarVC.monthAndYear = (aMonthAfter.year * 100) + aMonthAfter.month
        updateLabel(with: dateToDeliver)
    }
    
    // MARK: - Month Label
    private func updateLabel(with date: Date)  {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM YYYY"
        monthLabel.text = formatter.string(from: date)
    }
    
    // MARK: Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        overrideUserInterfaceStyle = .light
        scrollCalendarView.delegate = self
        assignViewForEachCalendar()
        initDatePicker()
        deliverDate(Date())
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        scrollCalendarView.scrollToChild(currentCalendarView)
        deliverDate(Date())
        
    }
    
    private func assignViewForEachCalendar() {
        prevCalendarVC.calendarView = prevCalendarView
        currentCalendarVC.calendarView = currentCalendarView
        nextCalendarVC.calendarView = nextCalendarView
    }
    private func initDatePicker() {
        datePickerModal.layer.borderWidth = 2
        datePickerModal.layer.borderColor = UIColor.black.cgColor
        datePickerModal.layer.cornerRadius = 10
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePickerModal.addSubview(datePicker)
        datePicker.addTarget(self, action: #selector(selectDateInDatePicker(_:)), for: .valueChanged)
    }

}

