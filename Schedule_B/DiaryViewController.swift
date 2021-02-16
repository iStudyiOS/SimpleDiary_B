//
//  ViewController.swift
//  Schedule_B
//
//  Created by KEEN on 2021/02/08.
//

import UIKit
import FSCalendar

class DiaryViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var diaryCalendarView: FSCalendar!
  
  var memos = [Memo]()

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
    
    laodDummyData()
  }

  @IBAction func unwindToMemoList(sender: UIStoryboardSegue) {
    if let sourceVC = sender.source as? DetailMemoViewController, let memo = sourceVC.memo {
      let newMemo = IndexPath(row: memos.count, section: 0)
      memos.append(memo)
      tableView.insertRows(at: [newMemo], with: .automatic)
    }
  }
  
  func laodDummyData() {
    let memo1 = Memo(mainText: "메모1", contentText: "메모1 detail")
    let memo2 = Memo(mainText: "메모2", contentText: "메모2 detail")
    let memo3 = Memo(mainText: "메모3", contentText: "메모3 detail")
    
    memos += [memo1, memo2, memo3]
  }
}

extension DiaryViewController: UITableViewDelegate{
}

extension DiaryViewController: UITableViewDataSource{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return memos.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "memoCell", for: indexPath) as! MemoListTableViewCell
    let memo = memos[indexPath.row]
    
    cell.mainText.text = memo.mainText
    cell.subText.text = formatter.string(from: memo.subText)
    return cell
  }
}

