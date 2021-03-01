//
//  DailyCellAlldaySchedulView.swift
//  Schedule_B
//
//  Created by Shin on 2/27/21.
//

import SwiftUI

struct DailyTableAlldaySchedule: View {
    private let schedules: [Schedule]
    private let tapSchedule: (Schedule) -> Void
    private let titleColor = Color(UIColor(rgb: 0x161d6f))
    private let descriptionColor = Color(UIColor(rgb: 0x276678))
    var body: some View {
        GeometryReader{ geometry in
            VStack {
                Text("All day schedule")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.pink)
                    .padding(.bottom, 10)
                ForEach(schedules){ schedule in
                    HStack {
                        Text(schedule.title)
                            .font(.title3)
                            .foregroundColor(titleColor)
                        Text(schedule.description)
                            .font(.caption)
                            .offset(y: 5)
                            .foregroundColor(descriptionColor)
                    }
                    .padding(.bottom, 10)
                    .offset(x: 20)
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 0)
                        .foregroundColor(Color(UIColor(rgb: 0xe7e6e1)))
                        .opacity(0.2)
                        .border(Color(UIColor(rgb: 0xfb743e)), width: 5)
                        .cornerRadius(10)
                        .frame(width: geometry.size.width * 0.8,
                               height: geometry.size.height * 0.2)
            )
        }
    }
    init(schedules: [Schedule], tapScheduleHandeler: @escaping (Schedule) -> Void) {
        self.schedules = schedules
        self.tapSchedule = tapScheduleHandeler
    }
}



