//
//  CellContentsView.swift
//  Simple Diary
//
//  Created by Shin on 2/8/21.
//

import SwiftUI

struct CellContentsView: View {
    var date: Int?
    var isToday = false
    var schedules = [Schedule]()
    private var filteredSchedules: Array<Schedule>.SubSequence {
        // fillter by priority
        schedules.sorted { lhs, rhs in
            if lhs.priority == rhs.priority {
                return lhs > rhs
            }else {
                return lhs.priority < rhs.priority
            }
        }.prefix(3)
    }
    private var dateFontColor: Color {
        Color.forDate(date!.toDate()!)
    }
    
    var body: some View {
        if date != nil {
            GeometryReader{ geometry in
                Text(String(date! % 100))
                    .font(.body)
                    .foregroundColor(dateFontColor)
                    .padding(3)
                    .overlay(isToday ? RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red.opacity(0.8),
                                        lineWidth: 2.5)
                                : nil)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.2)
                VStack{
                    ForEach(filteredSchedules, id:\.id) { schedule in
                        HStack{
                            RoundedRectangle(cornerRadius: 10, style: .circular)
                                .inset(by: CGFloat(4 - schedules.count))
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
                .padding(.top, 25)
            }
        }
    }
}

struct CellContentsView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader{ geometry in
            CellContentsView(date: 20210201,
                             isToday: true,
                             schedules: [])
                .frame(width: geometry.size.width * 0.2,
                       height: geometry.size.height * 0.2)
                .border(Color.black)
                .position(x: geometry.size.width / 2,
                          y: geometry.size.height / 2)
                
        }
    }
}
