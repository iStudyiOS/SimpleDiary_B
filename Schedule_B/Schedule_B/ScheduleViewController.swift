//
//  ScheduleViewController.swift
//  Schedule_B
//
//  Created by KEEN on 2021/02/09.
//

import UIKit
import FSCalendar

class ScheduleViewController: UIViewController {

  @IBOutlet weak var scheduleCalendarView: FSCalendar!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      scheduleCalendarView.backgroundColor = UIColor(red: 252/255, green: 232/255, blue: 239/255, alpha: 1)
      scheduleCalendarView.appearance.selectionColor = UIColor(red: 240/255, green: 100/255, blue: 100/255, alpha: 1)
      scheduleCalendarView.appearance.todayColor = UIColor(red: 249/255, green: 165/255, blue: 160/255, alpha: 1)
      scheduleCalendarView.appearance.headerTitleColor = UIColor(red: 180/255, green: 39/255, blue: 0/255, alpha: 1)
      scheduleCalendarView.appearance.weekdayTextColor = UIColor(red: 180/255, green: 39/255, blue: 0/255, alpha: 1)
      
      scheduleCalendarView.scrollEnabled = true
      scheduleCalendarView.scrollDirection = .vertical

    }

}
