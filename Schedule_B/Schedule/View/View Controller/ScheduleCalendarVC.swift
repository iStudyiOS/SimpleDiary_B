

import UIKit

class ScheduleCalendarViewController: UIViewController, UIScrollViewDelegate {
    
    weak var modelController: ScheduleModelController!
   
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var nextCalendarView: UICollectionView!
    @IBOutlet weak var currentCalendarView: UICollectionView!
    @IBOutlet weak var prevCalendarView: UICollectionView!
    @IBOutlet weak var scrollCalendarView: UIScrollView!
    @IBOutlet weak var datePickerModal: UIView!
    
    // MARK:- User intents
    
    @IBAction func tapSearchButton(_ sender: Any) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > 30 && scrollView.contentOffset.x < 780 {
            return
        }
        let firstDate = scrollView.contentOffset.x < 30 ?  Calendar.firstDateOfMonth(prevCalendarVC.yearAndMonth) :
            Calendar.firstDateOfMonth(nextCalendarVC.yearAndMonth)

        let aMonthAgo = Date.aMonthAgo(from: firstDate)
        let aMonthAfter = Date.aMonthAfter(from: firstDate)

        currentCalendarVC.yearAndMonth = (firstDate.year * 100) + firstDate.month
        prevCalendarVC.yearAndMonth = (aMonthAgo.year * 100) + aMonthAgo.month
        nextCalendarVC.yearAndMonth = (aMonthAfter.year * 100) + aMonthAfter.month
        updateLabel(with: firstDate)
        scrollView.scrollToChild(currentCalendarView)
    }
    
    // MARK:- Date picker
    
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
    
    //MARK:- Update trigger
    
    @objc private func deliverDate(_ dateToDeliver: Date) {
        currentCalendarVC.yearAndMonth = (dateToDeliver.year * 100) + dateToDeliver.month
        let aMonthAgo = Date.aMonthAgo(from: dateToDeliver)
        prevCalendarVC.yearAndMonth = (aMonthAgo.year * 100) + aMonthAgo.month
        let aMonthAfter = Date.aMonthAfter(from: dateToDeliver)
        nextCalendarVC.yearAndMonth = (aMonthAfter.year * 100) + aMonthAfter.month
        updateLabel(with: dateToDeliver)
    }
    
    private func updateLabel(with date: Date)  {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM YYYY"
        monthLabel.text = formatter.string(from: date)
    }
    
    // MARK:- Init
    
    private let today = Date()
    
    lazy private var currentCalendarVC =  SingleCalendarViewController(
        of: currentCalendarView,
        on: today.toInt() / 100,
        modelController: modelController)
    lazy private var prevCalendarVC = SingleCalendarViewController(
        of: prevCalendarView,
        on: (Date.aMonthAgo(from: today).toInt() / 100),
        modelController: modelController)
    lazy private var nextCalendarVC =
        SingleCalendarViewController(
            of: nextCalendarView,
            on:(Date.aMonthAgo(from: today).toInt() / 100),
            modelController: modelController)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        overrideUserInterfaceStyle = .light
        scrollCalendarView.delegate = self
        updateLabel(with: today)
        initDatePicker()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        scrollCalendarView.scrollToChild(currentCalendarView)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        deliverDate(Date())
    }
    private func initDatePicker() {
        datePickerModal.layer.borderWidth = 2
        datePickerModal.layer.borderColor = CGColor.salmon 
        datePickerModal.layer.cornerRadius = 10
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePickerModal.addSubview(datePicker)
        datePicker.addTarget(self, action: #selector(selectDateInDatePicker(_:)), for: .valueChanged)
    }
    
}

