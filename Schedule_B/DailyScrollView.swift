//
//  DailyScrollView.swift
//  Schedule_B
//
//  Created by Shin on 2/26/21.
//

import SwiftUI

struct DailyScrollView: View, DailyScrollViewProtocol {

    // MARK: Data
    /// Date current presenting
     var date: Date? {
        didSet {
            isToday = date!.isSameDay(with: Date())
        }
    }
    private var isToday = false
    private var _schedules = [Schedule]()
    private var schedulesAllDay = [Schedule]()
    private var schedulesOverlapped = [[Schedule]]()
    private let tapSchedule: ((Schedule) -> Void)
 
    var schedules: [Schedule] {
        set {
            _schedules.removeAll()
            schedulesAllDay.removeAll()
            schedulesOverlapped.removeAll()
            // Seperate schedules overlapped for each
            var overlappedIndices = Set<Int>()
            for (index, schedule) in newValue.enumerated() {
                if case .period(let startDate, let endDate) = schedule.time,
                   !startDate.isSameDay(with: date!),
                   !endDate.isSameDay(with: date!){
                    schedulesAllDay.append(schedule)
                    continue
                }
                if overlappedIndices.contains(index) {
                    continue
                }
                let overlappingToSchedule = findOverlappingIndex(of: schedule,
                                                                 in: newValue)
                if overlappingToSchedule.count == 1 {
                    _schedules.append(schedule)
                }else {
                    overlappingToSchedule.forEach {
                        overlappedIndices.insert($0)
                    }
                    let overlappedSchedules = overlappingToSchedule.compactMap {
                        newValue[$0]
                    }
                    schedulesOverlapped.append(overlappedSchedules)
                }
            }
        }
        get {
            _schedules
        }
    }
    private func findOverlappingIndex(of schedule: Schedule, in scheduleArr: [Schedule]) -> [Int] {
        var indices = [Int]()
        let rangeOfSchedule = calcTimeRange(of: schedule)
        for (index, scheduleToCheck) in scheduleArr.enumerated() {
            if schedulesAllDay.contains(scheduleToCheck) {
                continue
            }
            if rangeOfSchedule.overlaps(calcTimeRange(of: scheduleToCheck)) {
                indices.append(index)
            }
        }
        return indices
    }
    
    private func calcTimeRange(of schedule: Schedule) -> ClosedRange<TimeInterval> {
        switch schedule.time {
        case .spot(let date):
            let time = date.timeIntervalSinceReferenceDate
            return (time - TimeInterval(60 * 30)) ...
                time + TimeInterval(60 * 30)
        case .period(start: let startDate, end: let endDate):
            let startTime = max(startDate.timeIntervalSinceReferenceDate, date!.startOfDay.timeIntervalSinceReferenceDate)
            let nextDate = date!.addingTimeInterval(TimeInterval.forOneDay)
            let endTime = min(endDate.timeIntervalSinceReferenceDate,
                              nextDate.timeIntervalSinceReferenceDate)
            return startTime ... endTime
        case .cycle(since: let date, _, _):
            let time = date.timeIntervalSinceReferenceDate
            return (time - TimeInterval(60 * 30)) ...
                time + TimeInterval(60 * 30)
        }
    }
    
    // MARK:- View Properties
    private let lineHeight: CGFloat = 50
    private var scrollViewHeight: CGFloat {
        lineHeight * 24
    }
    // ID for scroll view
    private var scrollviewProxy: ScrollViewProxy?
    private let timeLineID = "currentTimeLine"
    
    var body: some View {
        ScrollViewReader { scrollviewProxy in
            GeometryReader { geometryProxy in
                ScrollView {
                    ZStack{
                        // MARK:- Base lines
                        DailyTableBaseLine(width: 450, lineHeight: lineHeight)
                        if isToday {
                            DailyTableCurrentTimeLine(scrollHeight: scrollViewHeight,
                                in: geometryProxy.size)
                                .id(timeLineID)
                                .onAppear {
                                    withAnimation {
                                        scrollviewProxy.scrollTo(timeLineID)
                                    }
                                }
                        }
                        Group {
                            ForEach(Array(schedules.enumerated()), id: \.offset) { index, schedule in
                                // Find y position of schedule
                                let yMultiplier = calcYPostionMultiplier(for: schedule.time)
                                
                                ZStack(alignment: .leading) {
                                    // MARK:- Background color
                                    DailyTableScheduleBackground(
                                        for: schedule,
                                        in: geometryProxy.size,
                                        date: date!)
                                    // MARK: - Schedule Content
                                    DailyScheduleContentsView(for: schedule)
                                        .frame(
                                            width: geometryProxy.size.width,
                                            height: scrollViewHeight * min(calcHeightRatio(for: schedule.time), 0.3))
                                        .offset(y: 30)
                                        
                                }
                                .position(x: geometryProxy.size.width * 0.75,
                                          y: lineHeight * CGFloat(yMultiplier == 0 ? 3 : yMultiplier) * 1.23)
                                .onTapGesture {
                                    tapSchedule(schedule)
                                }
                            }
                            // Draw group of schedule overlapped for each
                            ForEach(schedulesOverlapped, id: \.first!.id) { scheduleGroup in
                                DailyOverlappedCell(for: scheduleGroup,
                                                    date: date!,
                                                    tapScheduleHandeler: tapSchedule)
                                    .frame(width: geometryProxy.size.width * 0.6)
                                    .offset(x: geometryProxy.size.width * 0.1)
                            }
                        }
                        if !schedulesAllDay.isEmpty {
                            DailyTableAlldaySchedule(schedules: schedulesAllDay,
                                                     tapScheduleHandeler: tapSchedule)
                                .frame(width: geometryProxy.size.width * 0.8,
                                       height: geometryProxy.size.height * 0.8 * CGFloat(schedulesAllDay.count))
                                .position(x: geometryProxy.size.width * 0.8,
                                          y: geometryProxy.size.height * 0.5)
                            
                        }
                    }
                }
            }
        }
    }
    init(tapScheduleHandeler: @escaping (Schedule) -> Void) {
        self.tapSchedule = tapScheduleHandeler
    }
}
