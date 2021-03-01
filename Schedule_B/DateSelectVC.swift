//
//  DateSelectVC.swift
//  Schedule_B
//
//  Created by Shin on 2/28/21.
//

import SwiftUI

class DateSelectVC: UIViewController {
    
    // MARK: Controller
    var cyclePicker = UIHostingController(rootView: MultiSegmentView())
    var recievedDate: Date?
    
    // MARK:- Properties
    func getDatePicked() -> Schedule.DateType? {
        switch viewIndexPresenting {
        case 0:
            return .spot(spotDatePicker.date)
        case 1:
            if startDatePicker.date < endDatePicker.date {
                return .period(start: startDatePicker.date, end: endDatePicker.date)
            }else {
                return nil
            }
        case 2:
            return .cycle(since: Date(), for: .weekday, every: Array(cyclePicker.rootView.selectedIndices))
        case 3:
            return .cycle(since: Date(), for: .day, every: Array(cyclePicker.rootView.selectedIndices))
        default:
            return nil
        }
    }
    @IBOutlet weak var spotPickerView: UIView!
    @IBOutlet weak var spotDatePicker: UIDatePicker!
    @IBOutlet weak var periodPickerView: UIView!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var cyclePickerView: UIView!
    
    /// [ 0: spot, 1: period, 2: cycle]
    var viewIndexPresenting = 0 {
        didSet {
            spotPickerView.isHidden = viewIndexPresenting != 0
            periodPickerView.isHidden = viewIndexPresenting != 1
            cyclePickerView.isHidden = viewIndexPresenting != 2 && viewIndexPresenting != 3
            if viewIndexPresenting == 2 {
                // Weekly cycle
                cyclePicker.rootView.currentSegmentType = .weekly
            }else if viewIndexPresenting == 3 {
                // Monthly cycle
                cyclePicker.rootView.currentSegmentType = .monthly
            }
        }
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(cyclePicker)
        cyclePicker.view.frame = cyclePickerView.frame
        cyclePickerView.addSubview(cyclePicker.view)
        cyclePicker.didMove(toParent: self)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if recievedDate != nil {
            spotDatePicker.date = recievedDate!
            startDatePicker.date = recievedDate!
            endDatePicker.date = Calendar.current.date(byAdding: .day, value: 1, to: recievedDate!)!
        }
    }
}
