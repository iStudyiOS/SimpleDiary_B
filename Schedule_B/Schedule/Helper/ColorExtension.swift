//
//  Color.swift
//  Schedule_B
//
//  Created by Shin on 2/11/21.
//

import SwiftUI

extension CGColor {
    static var salmon: CGColor {
        CGColor(red: 0.98, green: 0.52, blue: 0.55, alpha: 0.8)
    }
}
extension Color {
    static func forDate(_ date: Date) -> Color {
        if date.weekDay == 0 {
            return Color.pink
        }else if date.weekDay == 6 {
            return Color.blue
        }else {
            return Color.black
        }
    }
    static func byPriority(_ priority: Int) -> Color {
        guard priority > 0 , priority < 6 else {
            fatalError("Drawing fail: Invalid priority of schedule is passed to cell")
        }
        switch priority {
        case 1:
            return Color.red
        case 2:
            return Color.orange
        case 3:
            return Color.green
        case 4:
            return Color.blue
        default:
            return Color.black
        }
    }
}
