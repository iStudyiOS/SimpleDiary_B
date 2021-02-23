//
//  SingleCalendarVC.swift
//  Schedule_B
//
//  Created by KEEN on 2021/02/23.
//

import UIKit
import Combine

class SingleCalendarViewController: UIViewController, ScheduleCollectionVC {
  // MARK: Controller
  
  var modelController: ScheduleModelController!
  
  // MARK:- Properties
  var calendarView: UICollectionView!
  private var observeDateTableCancellable: AnyCancellable?
  private var observeCycleTableCancellable: AnyCancellable?
  private var showDailyViewSegue: (String, Any) -> Void?
  private let today = Date()
  
  var yearAndMonth: Int{
    didSet{
      updateCalendar()
    }
  }
  
  var searchRequest = SearchRequest(priority: nil, text: nil) {
    didSet {
      calendarView.reloadData()
    }
  }
  
  struct SearchRequest {
    var priority: Int?
    var text: String?
  }
  var squaresInCalendarView = [Int?]()
  
  private func updateCalendar() {
    guard yearAndMonth > 190001 && yearAndMonth < 20500101 else {
      fatalError("Attemp to update calendar with invaild year")
    }
    squaresInCalendarView.removeAll()
    let totalDays = Calendar.getDaysInMonth(yearAndMonth)
    let firstDay = Calendar.firstDateOfMonth(yearAndMonth)
    let startSqureNumber = firstDay.weekDay - 1
    
    for index in 0...41 {
      if index < startSqureNumber || (index - startSqureNumber + 1) > totalDays{
        squaresInCalendarView.append(nil)
      }else {
        let date = index - startSqureNumber + 1
        squaresInCalendarView.append((yearAndMonth * 100) + date)
      }
    }
    calendarView.reloadData()
  }
  
  // MARK:- Collection view delegate
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    squaresInCalendarView.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    var cell = calendarView.dequeueReusableCell(
      withReuseIdentifier: "CalendarCell",
      for: indexPath) as! CalendarCellVC
    cell = modifyCalendarCell(cell, at: indexPath, calendarView: calendarView)
    if !isEmptyCell(cell) {
      cell.cellView.searchRequest = searchRequest
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CalendarCellVC.size(in: (calendarView.frame.size))
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let dateToShow = squaresInCalendarView[indexPath.row]{
      showDailyViewSegue("ShowDailyView", dateToShow)
    }
  }
  
  // MARK:- init
  
  init(of calendarView: UICollectionView, on yearAndMonth: Int, modelController: ScheduleModelController, segue: @escaping (String, Any) -> Void = { _,_  in}) {
    self.calendarView = calendarView
    self.yearAndMonth = yearAndMonth
    self.modelController = modelController
    self.showDailyViewSegue = segue
    super.init(nibName: nil, bundle: nil)
    self.observeDateTableCancellable = modelController.$scheduleTable.sink() { [weak weakSelf = self] table in
      weakSelf?.updateCalendar()
    }
    self.observeCycleTableCancellable =
      modelController.$cycleTable.sink() { [weak weakSelf = self] table in
        weakSelf?.updateCalendar()
      }
    
    calendarView.isScrollEnabled = false
    calendarView.dataSource = self
    calendarView.delegate = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
