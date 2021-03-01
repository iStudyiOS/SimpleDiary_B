//
//  DailyCellContentsView.swift
//  Schedule_B
//
//  Created by Shin on 2/27/21.
//

import SwiftUI

struct DailyScheduleContentsView: View {
    // MARK: Data
    private let schedule: Schedule
    
    // MARK:- View properties
    private let titleColor = Color(UIColor(rgb: 0x493323))
    private let descriptionColor = Color(UIColor(rgb: 557174))
    private let alarmButtonColor = Color(UIColor(rgb: 0xeb596e))
    private func normalizeSize(_ size: CGSize) -> CGSize {
        if size.height > 100 {
            return CGSize(width: size.width,
                          height: size.height / 2)
        }else {
            return size
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = normalizeSize(geometry.size)
            Text(schedule.title)
                .font(schedule.title.count > 10 ? .body : .title2)
                .bold()
                .position(x: schedule.title.count > 10 ? size.width * 0.3 : size.width * 0.2,
                          y: size.height * 0.2)
                .foregroundColor(titleColor)
            Text(schedule.description)
                .font(schedule.description.count > 10 ? .caption : .body)
                .lineLimit(2)
                .position(x: schedule.description.count > 10 ? size.width * 0.4 : size.width * 0.2,
                          y: size.height * 0.5)
                .foregroundColor(descriptionColor)
            if schedule.alarm != nil {
                Button(action: {
                    // TODO: Turn off alarm
                    
                }, label: {
                    Image(systemName: schedule.isAlarmOn ? "alarm.fill" : "alarm")
                        .scaleEffect(CGSize(width: 1.5, height: 1.5))
                        .foregroundColor(schedule.isAlarmOn ? alarmButtonColor : .gray)
                })
                .position(x: size.width * 0.4,
                          y: size.height * 0.7)
            }
        }
    }
    init(for schedule: Schedule) {
        self.schedule = schedule
    }
}

struct DailyCellContentsView_Previews: PreviewProvider {
    static var previews: some View {
        DailyScheduleContentsView(for:
                                Schedule(
                                    title: "Go to eat",
                                    description: "Some food",
                                    priority: 1,
                                    time: .spot(Date()),
                                    alarm: .once(Date())
                                )
        )
        .frame(width: 500, height: 150)
    }
}
