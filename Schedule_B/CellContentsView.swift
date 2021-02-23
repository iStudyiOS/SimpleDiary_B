//
//  CellContentsView.swift
//  Schedule_B
//
//  Created by KEEN on 2021/02/23.
//

import SwiftUI

struct CellContentsView: View {
  var date: Int?
  var isToday = false
  var schedules = [Schedule]()
  var searchRequest: SingleCalendarViewController.SearchRequest?
  var holiday: HolidayGather.Holiday?
  private var filteredSchedules: Array<Schedule>.SubSequence {
    let filtered = schedules.filter() {
      if let search = searchRequest {
        if search.priority != nil, search.priority != $0.priority{
          return false
        }
        if search.text != nil{
          return $0.title.lowercased().contains(search.text!) || $0.description.lowercased().contains(search.text!)
        }else {
          return true
        }
      }else {
        return true
      }
    }
    // fillter by priority
    return filtered.sorted { lhs, rhs in
      if lhs.priority == rhs.priority {
        return lhs > rhs
      }else {
        return lhs.priority < rhs.priority
      }
    }.prefix(3)
  }
  private var dateFontColor: Color {
    if holiday != nil {
      if date!.toDate!.weekDay == 1 || holiday!.type == .national {
        return Color.red
      }else if date!.toDate!.weekDay == 7 {
        return Color.blue
      }else {
        return Color.gray
      }
    }else {
      return Color.forDate(date!.toDate!)
    }
  }
  
  var body: some View {
    if date != nil {
      GeometryReader{ geometry in
        VStack{
          Text(String(date! % 100))
            .font(.body)
            .overlay(isToday ? RoundedRectangle(
                      cornerRadius: 10)
                      .stroke(Color.red.opacity(0.8),
                              lineWidth: 2.5)
                      : nil)
          if holiday != nil{
            Text(holiday!.title)
              .font(.system(size: 10))
              .lineLimit(1)
          }
        }
        .foregroundColor(dateFontColor)
        .padding(3)
        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.2)
        VStack{
          ForEach(filteredSchedules, id:\.id) { schedule in
            HStack{
              RoundedRectangle(cornerRadius: 10, style: .circular)
                .inset(by: CGFloat(4.5 - Double(schedules.count)))
                .fill(Color.byPriority(schedule.priority))
                .aspectRatio(0.3, contentMode: .fit)
              Text(schedule.title)
                .font(.system(size: 10))
                .lineLimit(1)
                .foregroundColor(Color.byPriority(schedule.priority))
                .padding(.leading, -7)
            }
            .frame(width: geometry.size.width,
                   height:
                    (geometry.size.height * 0.7) / CGFloat(schedules.count + 1))
          }
        }
        .padding(.top, holiday == nil ? 25: 35)
      }
    }
  }
}
