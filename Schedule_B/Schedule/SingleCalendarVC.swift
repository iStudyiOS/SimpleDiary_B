

import UIKit

class SingleCalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var calendarView: UICollectionView
    
    private let today = Date()
    
    private var todayToInt: Int {
        (today.year * 10000) + (today.month * 100) + today.day
    }
    
    // MARK:- Controll calendar month
    var yearAndMonth: Int{
        didSet{
            updateCalendar()
        }
    }
    
    private var squaresInCalendarView = [Int?]()
    
    private func updateCalendar() {
        guard yearAndMonth > 190001 && yearAndMonth < 20500101 else {
            fatalError("Attemp to update calendar with invaild year")
        }
        squaresInCalendarView.removeAll()
        let totalDays = Calendar.getDaysInMonth(yearAndMonth)
        let firstDay = Calendar.firstDateOfMonth(yearAndMonth)
        let startSqureNumber = firstDay.weekDay
        for index in 0...41 {
            if index < startSqureNumber || (index - startSqureNumber + 1) > totalDays{
                squaresInCalendarView.append(nil)
            }else {
                let date = index - startSqureNumber + 1
                squaresInCalendarView.append((yearAndMonth * 100) + date)
            }
        }
        calendarView.reloadData()
    }
    
    // MARK:- Collection view delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        squaresInCalendarView.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = calendarView.dequeueReusableCell(
            withReuseIdentifier: "CalendarCell",
            for: indexPath) as! CalendarCellVC
        let date = squaresInCalendarView[indexPath.item]
        if date != nil {
            // toss data to cell
            cell.hostingController.rootView.date = date
            cell.hostingController.rootView.isToday = date! == todayToInt
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
        return CalendarCellVC.size(in: (calendarView.frame.size))
    }
    
    init(withCalendar calendarView: UICollectionView, on yearAndMonth: Int) {
        self.calendarView = calendarView
        self.yearAndMonth = yearAndMonth
        super.init(nibName: nil, bundle: nil)
        calendarView.isScrollEnabled = false
        calendarView.dataSource = self
        calendarView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
