

import UIKit

class SingleCalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var calendarView: UICollectionView? {
        didSet {
            calendarView?.isScrollEnabled = false
            calendarView?.dataSource = self
            calendarView?.delegate = self
        }
    }
    
    let today = (Date().year * 10000) + (Date().month * 100) + Date().day
    var monthAndYear: Int = 0 {
        didSet{
            updateCalendar()
        }
    }
    private var squaresInCalendarView = [Int?]()
    
    private func updateCalendar() {
        guard monthAndYear > 190001 else {
            return
        }
        squaresInCalendarView.removeAll()
        let totalDays = Calendar.getDaysInMonth(monthAndYear)
        let firstDay = Calendar.firstDateOfMonth(monthAndYear)
        let startSqureNumber = firstDay.weekDay
        for index in 0...41 {
            if index < startSqureNumber || (index - startSqureNumber + 1) > totalDays{
                squaresInCalendarView.append(nil)
            }else {
                let date = index - startSqureNumber + 1
                squaresInCalendarView.append((monthAndYear * 100) + date)
            }
        }
        calendarView?.reloadData()
    }
    
    // MARK: Collection view delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        squaresInCalendarView.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = calendarView?.dequeueReusableCell(
            withReuseIdentifier: "CalendarCell",
            for: indexPath) as! CalendarCellVC
        let date = squaresInCalendarView[indexPath.item]
        if date != nil {
            // toss data to cell
            cell.hostingController.rootView.date = date
            cell.hostingController.rootView.isToday = date! == today
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CalendarCellVC.size(in: (calendarView?.frame.size)!)
    }
}
