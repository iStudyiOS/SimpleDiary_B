//
//  ScheduleExtension.swift
//  Schedule_B
//
//  Created by Shin on 2/26/21.
//

import Foundation

extension Array where Element == Schedule {
    var sortedByPriority: [Schedule] {
        var toSort = self
        toSort.sort { lhs, rhs in
            if lhs.priority == rhs.priority {
                return lhs > rhs
            }else {
                return lhs.priority < rhs.priority
            }
        }
        return toSort
    }
}
