//
//  CalendarExtension.swift
//  Schedule_B
//
//  Created by KEEN on 2021/02/23.
//

import Foundation

extension Calendar {
  static func getDaysInMonth(_ yearAndMonth: Int) -> Int {
    let firstDate = firstDateOfMonth(yearAndMonth)
    let range = Calendar.current.range(
      of: .day,
      in: .month,
      for: firstDate)
    return range!.count
  }
  static func firstDateOfMonth(_ yearAndMonth: Int) -> Date {
    return DateComponents(
      calendar: Calendar.current,
      timeZone: .current,
      year: yearAndMonth / 100,
      month: yearAndMonth % 100).date!
  }
}

extension Date {
  var year: Int {
    Calendar.current.component(.year, from: self)
  }
  var month: Int {
    Calendar.current.component(.month, from: self)
  }
  var day: Int {
    Calendar.current.component(.day, from: self)
  }
  var weekDay: Int {
    Calendar.current.component(.weekday, from: self)
  }
  var hour: Int {
    Calendar.current.component(.hour, from: self)
  }
  var minute: Int {
    Calendar.current.component(.minute, from: self)
  }
  
  var aMonthAgo: Date {
    return Calendar.current.date(
      byAdding: DateComponents(month: -1), to: self)!
  }
  var aMonthAfter: Date {
    return Calendar.current.date(
      byAdding: DateComponents(month: 1), to: self)!
  }
  func isSameDay(with toCompare: Date) -> Bool {
    return self.year == toCompare.year && self.month == toCompare.month && self.day == toCompare.day
  }
  var toInt: Int {
    return (self.year * 10000) + (self.month * 100) + self.day
  }
  func getNext(by component: ComponentType) -> Date{
    var nextComponent = Calendar.current.dateComponents([.hour, .minute], from: self)
    
    switch component {
    case .day(let day):
      nextComponent.day = day
    case .weekday(let weekday):
      nextComponent.weekday = weekday
    }
    
    return Calendar.current.nextDate(
      after: self,
      matching: nextComponent,
      matchingPolicy: .nextTime)!
  }
  enum ComponentType {
    case day (Int)
    case weekday (Int)
  }
}

extension Int {
  var toDate: Date?{
    DateComponents(
      calendar: Calendar.current,
      timeZone: .current,
      year: self / 10000,
      month: (self / 100) % 100,
      day: self % 100).date
  }
}
