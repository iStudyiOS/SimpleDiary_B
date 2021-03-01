//
//  DailyTableScheduleBackground.swift
//  Schedule_B
//
//  Created by Shin on 2/28/21.
//

import SwiftUI

struct DailyTableScheduleBackground: DailyScrollViewProtocol {
    var date: Date?
    
    let schedule: Schedule
    let size: CGSize
    
    var body: some View {
        Rectangle()
            .frame(
                width: size.width,
                height: size.height * max(calcHeightRatio(for: schedule.time) * 1.8, 0.1))
            .foregroundColor(Color.byPriority(schedule.priority))
            .opacity(0.4)
        
    }
    init(for schedule:Schedule, in size: CGSize, date: Date) {
        self.schedule = schedule
        self.size = size
        self.date = date
    }
}
