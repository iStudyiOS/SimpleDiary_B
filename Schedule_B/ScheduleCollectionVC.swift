//
//  ScheduleViewController.swift
//  Schedule_B
//
//  Created by KEEN on 2021/02/09.
//

import UIKit

// MARK: View Controller draw UI collection view for schedule
protocol ScheduleCollectionVC: UIViewController & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout & UICollectionViewDataSource {
    var modelController: ScheduleModelController! { get set }
    /// Fill int value from date for each cell  ( 2021/02/14 -> 20210214) nil will draw empty cell
    var squaresInCalendarView: [Int?] { get set }
    
}
extension ScheduleCollectionVC {
    func modifyCalendarCell(_ cell: CalendarCellVC, at indexPath: IndexPath, calendarView: UICollectionView) -> CalendarCellVC {
        
        let dateInt = squaresInCalendarView[indexPath.item]
        if dateInt != nil {
            // toss data to cell
            cell.cellView.date = dateInt
            cell.cellView.isToday = dateInt! == Date().toInt
            cell.cellView.holiday = modelController.holidayTable[dateInt!]
            cell.cellView.schedules = modelController.getSchedules(for: dateInt!)
            // Add cell content with Swift UI
            cell.hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            cell.hostingController.view.frame = cell.contentView.frame
            cell.contentView.addSubview(cell.hostingController.view)
        }else {
            cell.hostingController.rootView.date = nil
            cell.hostingController.view.removeFromSuperview()
        }
        return cell
    }
    func isEmptyCell(_ cell: CalendarCellVC) -> Bool {
        return cell.cellView.date == nil
    }
}

