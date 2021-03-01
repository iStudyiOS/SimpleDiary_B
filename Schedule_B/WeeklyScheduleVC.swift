//
//  WeeklyScheduleVC.swift
//  Schedule_B
//
//  Created by Shin on 2/24/21.
//

import UIKit

class WeeklyScheduleVC: UIViewController, ScheduleCollectionVC {
    
    //MARK: Controllers
    var modelController: ScheduleModelController!
    
    //MARK:- Properties
    
    @IBOutlet weak var weeklyScheduleView: UICollectionView!
    internal var squaresInCalendarView = [Int?]()
    @Published var dateIntChosen: Int! {
        didSet {
            weeklyScheduleView?.reloadData()
        }
    }
    var dateChosen: Date {
        dateIntChosen.toDate!
    }
    private var isScrollingByCode = false
    private func scrollToCenter(by offSet: Int = 0) {
        isScrollingByCode = true
        weeklyScheduleView.scrollToItem(
            at: IndexPath(row: (squaresInCalendarView.count + offSet) / 2
                          , section: 0),
            at: .centeredHorizontally,
            animated: false)
        isScrollingByCode = false
    }
    
    //MARK:- Collection view controller delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return squaresInCalendarView.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = weeklyScheduleView.dequeueReusableCell(withReuseIdentifier: "TopViewScheduleCell", for: indexPath) as! WeeklyCell
        cell = drawCellForWeeklyView(cell, at: indexPath, calendarView: weeklyScheduleView)
        cell.weeklyCellView.isSelected = squaresInCalendarView[indexPath.row] == dateIntChosen
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return WeeklyCell.size(in: weeklyScheduleView.frame.size)
    }
    func initDataSource(with centralDate: Date) {
        squaresInCalendarView.removeAll()
        let startDate = Calendar.current.date(byAdding: .day, value: -14, to: centralDate)!
        let endDate = Calendar.current.date(byAdding: .day, value: 14, to: centralDate)!
        stride(from: startDate,
               to: endDate,
               by: TimeInterval.forOneDay).forEach{
            squaresInCalendarView.append($0.toInt)
        }
        weeklyScheduleView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dateIntChosen = squaresInCalendarView[indexPath.row]
    }
    
    // MARK:- Scroll view delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isScrollingByCode else { return }
        let halfOfTotal = squaresInCalendarView.count / 2
        if scrollView.contentOffset.x < 50,
           let currentFirst = squaresInCalendarView.first{
            let twoWeeksAgo = Calendar.current.date(
                byAdding: .day, value: -14, to: currentFirst!.toDate!)!
            let previousDays = stride(from: twoWeeksAgo,
                                      to: currentFirst!.toDate!,
                                      by: TimeInterval.forOneDay).compactMap{ $0.toInt}
            squaresInCalendarView = previousDays + squaresInCalendarView[...halfOfTotal]
            scrollToCenter(by: 2)
        }else if scrollView.contentOffset.x > 1500,
                 let currentLast = squaresInCalendarView.last{
            let dayAfterLast = Calendar.current.date(byAdding: .day,
                                                     value: 1,
                                                     to: currentLast!.toDate!)!
            let twoWeeksAfter = Calendar.current.date(
                byAdding: .day, value: 15, to: dayAfterLast)!
            let afterwardsDays = stride(from: dayAfterLast,
                                        to: twoWeeksAfter,
                                        by: TimeInterval.forOneDay).compactMap{
                                            $0.toInt
                                        }
            squaresInCalendarView = squaresInCalendarView[halfOfTotal...] + afterwardsDays
            scrollToCenter(by: -3)
        }
    }
    
    // MARK:- Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weeklyScheduleView.dataSource = self
        weeklyScheduleView.delegate = self
        initDataSource(with: dateIntChosen.toDate!)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToCenter()
    }
}
