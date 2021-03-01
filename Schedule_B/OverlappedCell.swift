//
//  DailyOverlappedCell.swift
//  Schedule_B
//
//  Created by Shin on 2/28/21.
//

import SwiftUI

struct DailyOverlappedCell: View, DailyScrollViewProtocol {
    
    // MARK: Data
    var date: Date?
    private let schedules: [Schedule]
    private let tapSchedule: (Schedule) -> Void
    // MARK:- View Properties
    
    private let titleColor = Color(UIColor(rgb: 0x28527a))
    
    var body: some View {
        GeometryReader{ geometry in
            Group{
                if schedules.count < 3 {
                    HStack(spacing: 60) {
                        ForEach(schedules) { schedule in
                            ZStack{
                                DailyTableScheduleBackground(
                                    for: schedule,
                                    in: CGSize(width: geometry.size.width * 0.6,
                                               height: geometry.size.height * 0.8),
                                    date: date!)
                                DailyScheduleContentsView(for: schedule)
                                    .offset(x: 30,
                                        y: geometry.size.height * max(calcHeightRatio(for: schedule.time), 0.15) * 0.25)
                                
                            }
                            .frame(width: geometry.size.width * 0.25,
                                   height: geometry.size.height * max(calcHeightRatio(for: schedule.time), 0.15))
                            .position(x: geometry.size.width * 0.15,
                                      y: geometry.size.height * CGFloat(calcYPostionMultiplier(for: schedule.time)) / 24)
                            .onTapGesture {
                                tapSchedule(schedule)
                            }
                        }
                    }
                }else {
                    HStack {
                        ForEach(schedules) { schedule in
                            Capsule(style: .circular)
                                .opacity(0.8)
                                .foregroundColor(Color.byPriority(schedule.priority))
                                .overlay(
                                    Text(schedule.title)
                                        .foregroundColor(titleColor)
                                )
                                .frame(width: geometry.size.width * 0.25,
                                       height: geometry.size.height * max(calcHeightRatio(for: schedule.time), 0.15))
                                .position(x: geometry.size.width * 0.15,
                                          y: geometry.size.height * CGFloat(calcYPostionMultiplier(for: schedule.time)) / 24)
                                .onTapGesture {
                                    tapSchedule(schedule)
                                }
                        }
                    }
                }
            }
            .frame(width: geometry.size.width,
                   height: geometry.size.height)
            
        }
    }
    init(for schedules: [Schedule], date: Date, tapScheduleHandeler: @escaping (Schedule) -> Void) {
        self.schedules = schedules
        self.date = date
        self.tapSchedule = tapScheduleHandeler
    }
}
