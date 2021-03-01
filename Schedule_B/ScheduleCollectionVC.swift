

import UIKit

// MARK: View Controller draw UI collection view for schedule
protocol ScheduleCollectionVC: UIViewController & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout & UICollectionViewDataSource {
    var modelController: ScheduleModelController! { get set }
    /// Fill int value from date for each cell  ( 2021/02/14 -> 20210214) nil will draw empty cell
    var squaresInCalendarView: [Int?] { get set }
    
}
extension ScheduleCollectionVC {
    func drawCellForCalendar(_ cell: CalendarCell, at indexPath: IndexPath, calendarView: UICollectionView) -> CalendarCell {
        
        let dateInt = squaresInCalendarView[indexPath.item]
        if dateInt != nil {
            // toss data to cell
            cell.calendarCellView.date = dateInt!.toDate
            cell.calendarCellView.holiday = modelController.holidayTable[dateInt!]
            cell.calendarCellView.schedules = modelController.getSchedules(for: dateInt!)
            // adjust swift ui view
            cell.calendarCellHC.view.translatesAutoresizingMaskIntoConstraints = false
            cell.calendarCellHC.view.frame = cell.contentView.frame
            cell.contentView.addSubview(cell.calendarCellHC.view)
        }else {
            cell.calendarCellHC.rootView.date = nil
            cell.calendarCellHC.view.removeFromSuperview()
        }
        return cell
    }
    func drawCellForWeeklyView(_ cell: WeeklyCell, at indexPath: IndexPath, calendarView: UICollectionView) -> WeeklyCell  {
        let dateInt = squaresInCalendarView[indexPath.item]!
        // toss date to cell
        cell.weeklyCellView.date = dateInt.toDate!
        cell.weeklyCellView.schedules = modelController.getSchedules(for: dateInt)
        cell.weeklyCellView.holiday = modelController.holidayTable[dateInt]
        // adjust swift ui view
        cell.weeklyCellHC.view.translatesAutoresizingMaskIntoConstraints = false
        cell.weeklyCellHC.view.frame = cell.contentView.frame
        cell.contentView.addSubview(cell.weeklyCellHC.view)
        cell.layer.borderColor = .init(gray: 0.5, alpha: 0.5)
        cell.layer.borderWidth = 0.8
        return cell
    }
    func isEmptyCell(_ cell: CalendarCell) -> Bool {
        return cell.calendarCellView.date == nil
    }
}

