//
//  DailySwiftUIView.swift
//  Schedule_B
//
//  Created by Shin on 2/28/21.
//

import SwiftUI

protocol DailyScrollViewProtocol: View {
    var date: Date? { get set }
}

extension DailyScrollViewProtocol {
    func calcYPostionMultiplier(for scheduleTime: Schedule.DateType)
    -> Int {
        switch scheduleTime {
        case .spot(let date):
            return date.hour
        case .period(start: let startDate, let endDate):
            if startDate.isSameDay(with: date!) {
                if endDate.isSameDay(with: startDate) {
                    return startDate.hour + (endDate.hour - startDate.hour) / 2
                }else {
                    return startDate.hour + (24 - startDate.hour) / 2
                }
            }else if endDate.isSameDay(with: date!){
                return (endDate.hour / 2)
            }else {
                // Not draw background
                return 0
            }
        case .cycle(let firstStartDate, _, _):
            return firstStartDate.hour
        }
    }
    func calcHeightRatio(for scheduleTime: Schedule.DateType) -> CGFloat
    {
        let minRatio: CGFloat = 0.1
        switch scheduleTime {
        case .spot(_):
            return minRatio
        case .period(start: let startDate, end: let endDate):
            let interval: TimeInterval
            if startDate.isSameDay(with: date!) {
                if endDate.isSameDay(with: date!) {
                    interval = endDate - startDate
                }else {
                    interval = TimeInterval.forOneDay - (startDate - startDate.startOfDay)
                }
            }else if endDate.isSameDay(with: date!){
                interval = endDate - date!.startOfDay
            }else {
                // Not draw indivisually
                return 0
            }
            return CGFloat(interval / TimeInterval.forOneDay * 1.3)
        case .cycle(since: _, _, _):
            return minRatio
        }
    }
}
