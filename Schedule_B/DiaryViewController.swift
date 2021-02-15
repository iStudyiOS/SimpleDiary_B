//
//  ViewController.swift
//  Schedule_B
//
//  Created by KEEN on 2021/02/08.
//

import UIKit
import FSCalendar

class DiaryViewController: UIViewController {

  @IBOutlet weak var diaryCalendarView: FSCalendar!
    
    let formatter : DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        f.locale = Locale(identifier: "Ko_kr")
        return f
    }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    diaryCalendarView.backgroundColor = UIColor(red: 241/255, green: 249/255, blue: 255/255, alpha: 1)
    diaryCalendarView.appearance.selectionColor = UIColor(red: 38/255, green: 153/255, blue: 251/255, alpha: 1)
    diaryCalendarView.appearance.todayColor = UIColor(red: 188/255, green: 224/255, blue: 253/255, alpha: 1)
    
    diaryCalendarView.scrollEnabled = true
    diaryCalendarView.scrollDirection = .vertical
  }

}

extension DiaryViewController: UITableViewDelegate{
    
}

extension DiaryViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MemoList.dummyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MemoListTableViewCell
        
        let target = MemoList.dummyList[indexPath.row]
        cell.mainText.text = target.mianText
        cell.subText.text = formatter.string(from: target.subText)
        return cell
    }
    
    
}
