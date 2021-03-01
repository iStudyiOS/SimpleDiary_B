//
//  EditScheduleVC.swift
//  Schedule_B
//
//  Created by Shin on 2/28/21.
//

import UIKit

class EditScheduleVC: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    
    // MARK: Controllers
    var modelController: ScheduleModelController!
    private var dateSelectVC: DateSelectVC!
    
    // MARK:- Properties
    var toEdit: Schedule?
    var recievedDate: Date?
    var currentPriority: Int {
        get {
            priority.selectedSegmentIndex + 1
        }
        set {
            priority.selectedSegmentIndex = newValue - 1
        }
    }
    private var currentAlarm: AlramState = .off
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var priority: UISegmentedControl!
    @IBOutlet weak var dateType: UISegmentedControl!
    @IBOutlet weak var alarmTime: UIDatePicker!
    @IBOutlet weak var descriptionInput: UITextView!
    
    // MARK:- User intents
    
    @IBAction func changeDateType(_ sender: UISegmentedControl) {
        dateSelectVC.viewIndexPresenting = sender.selectedSegmentIndex
    }
    @IBAction func turnAlarmButton(_ sender: UIButton) {
        currentAlarm = currentAlarm == .on ? .off : .on
        sender.tintColor = currentAlarm.getColor()
        sender.setTitleColor(currentAlarm.getColor(), for: .normal)
        alarmTime.isEnabled = currentAlarm == .on
    }
    @IBAction func tapCancelButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func changePriority(_ sender: UISegmentedControl) {
        titleLabel.textColor = UIColor.byPriority(currentPriority)
    }
    @IBAction func tapAddButton(_ sender: UIButton) {
        let message: String
        if let title = titleInput.text,
           !title.isEmpty{
            if let dateType = dateSelectVC.getDatePicked(){
                let alarm = getAlarm(by: dateType)
                let newSchedule = Schedule(
                    title: title,
                    description: descriptionInput.text == NewLineTextView.defaultDescription ? "" : descriptionInput.text,
                    priority: currentPriority,
                    time: dateType,
                    alarm: alarm)
                if !modelController.addNewSchedule(newSchedule) {
                    print("Fail to add schedule")
                }
                dismiss(animated: true)
                return
            }else {
                message = "일정의 기간을 확인해주세요"
            }
        }else {
            message = "제목을 입력해주세요"
        }
        let alertController = UIAlertController(
            title: "새로운 일정 등록 실패",
            message: message,
            preferredStyle: .actionSheet)
        let dissmissAction = UIAlertAction(
            title: "확인", style: .cancel)
        alertController.addAction(dissmissAction)
        present(alertController, animated: true)
    }
    
    private func getAlarm(by date: Schedule.DateType) -> Schedule.Alarm? {
        switch currentAlarm {
        case .on:
            if case .cycle(let startDate, _, _) = date {
                var components = Calendar.current.dateComponents(in: .current, from: startDate)
                components.hour = alarmTime.date.hour
                components.minute = alarmTime.date.minute
                return .periodic(components.date!)
            }else {
                var day: Date?
                if case let .spot(scheduleDate) = date {
                    day = scheduleDate
                }else if case let .period(startDate, _) = date {
                    day = startDate
                }
                var components = Calendar.current.dateComponents(in: .current, from: day!)
                components.hour = alarmTime.date.hour
                components.minute = alarmTime.date.minute
                return .once(components.date!)
            }
        case .off:
            return nil
        }
    }
    // MARK:- Init
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DatePickerSegue" ,
           let dateSelectVC = segue.destination as? DateSelectVC {
            self.dateSelectVC = dateSelectVC
            dateSelectVC.recievedDate = recievedDate
        }
    }
    
    override func viewDidLoad() {
        titleInput.delegate = self
        super.viewDidLoad()
        if toEdit != nil {
            titleLabel.text = "Change schedule"
            titleInput.text = toEdit!.title
            descriptionInput.text = toEdit?.description
            currentPriority = toEdit!.priority
            switch toEdit!.time {
            case .spot(let date):
                recievedDate = date
            case .period(start: let startDate, end: let endDate):
                recievedDate = startDate
                dateSelectVC?.startDatePicker.date = startDate
                dateSelectVC?.endDatePicker.date = endDate
            default:
                // TODO:- Init cycle picker by schedule to edit
                break
            }
        }
    }
    // MARK:- Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
   
    enum AlramState{
        case on
        case off
        func getColor() -> UIColor {
            switch self {
            case .on:
                return .systemPink
            case .off:
                return .lightGray
            }
        }
    }
}
