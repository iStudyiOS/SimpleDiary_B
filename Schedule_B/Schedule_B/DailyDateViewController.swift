//
//  DailyDateViewController.swift
//  Schedule_B
//
//  Created by 오현식 on 2021/02/15.
//

import UIKit

class DailyDateViewController: UIViewController {
    
    let day2: [Date] = [Date(day1:"Saturday",day2:6),Date(day1:"Sunday",day2:7),Date(day1:"Monday",day2:8),Date(day1:"Tuesday",day2:9),Date(day1:"Wednesday",day2:10)]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension DailyDateViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return day2.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as? DateCell else {
            return UICollectionViewCell()
        }
        let day = day2[indexPath.item]
        cell.update(date: day)
        return cell
    }
}

extension DailyDateViewController: UICollectionViewDelegate {
    
}

extension DailyDateViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.bounds.width/6
        let height: CGFloat = 50
        return CGSize(width: width, height: height)
    }
}

class DateCell: UICollectionViewCell {
    @IBOutlet weak var day1: UILabel!
    @IBOutlet weak var day2: UILabel!
    
    func update(date: Date) {
        day1.text = date.day1
        day2.text = "\(date.day2)"
    }
}

struct Date
{
    var day1: String
    var day2: Int
    init(day1: String, day2: Int) {
        self.day1 = day1
        self.day2 = day2
    }
}
