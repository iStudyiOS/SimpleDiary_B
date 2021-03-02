//
//  ViewController.swift
//  Schedule_B
//
//  Created by KEEN on 2021/02/08.
//

import UIKit
import FSCalendar

// TODO: 메모 수정 시, 새로운 메모로 추가 저장되는 부분 구현.

class DiaryViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var diaryCalendarView: FSCalendar!
  
  var editMemoType: Memo?
    
  let formatter : DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .short
    f.timeStyle = .short
    f.locale = Locale(identifier: "Ko_kr")
    return f
  }()
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    diaryCalendarView.backgroundColor = UIColor(red: 241/255, green: 249/255, blue: 255/255, alpha: 1)
    diaryCalendarView.appearance.selectionColor = UIColor(red: 38/255, green: 153/255, blue: 251/255, alpha: 1)
    diaryCalendarView.appearance.todayColor = UIColor(red: 188/255, green: 224/255, blue: 253/255, alpha: 1)
    
    diaryCalendarView.scrollEnabled = true
    diaryCalendarView.scrollDirection = .vertical
  }
  
  // MARK: 메모 cell 선택 시, detailVC에 데이터 연동하기
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let vc = segue.destination as? DetailMemoViewController else { return }
    guard let selectedMemoCell = sender as? MemoListTableViewCell else { return }
    guard let indexPath = tableView.indexPath(for: selectedMemoCell) else { return }
    
    let selectedMemo = Memo.dummyMemoList[indexPath.row]
    vc.memoType = selectedMemo
  }

  // MARK: 메모 생성 및 편집
  @IBAction func unwindToMemoList(sender: UIStoryboardSegue) {
    if let sourceVC = sender.source as? DetailMemoViewController, let memo = sourceVC.memoType {
      if let selectedIndexPath = tableView.indexPathForSelectedRow {
        // 존재하는 메모 업데이트
        Memo.dummyMemoList[selectedIndexPath.row] = memo
        tableView.reloadRows(at: [selectedIndexPath], with: .none)
      } else {
        // 새로운 메모 추가
        let newMemoIndexPath = IndexPath(row: Memo.dummyMemoList.count, section: 0)
        Memo.dummyMemoList.append(memo)
        tableView.insertRows(at: [newMemoIndexPath], with: .automatic)
      }
    }
  }
}



//
// MARK: Extension Delegate & DataSource

extension DiaryViewController: UITableViewDelegate{
  // MARK: 메모 삭제 관련 코드
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      Memo.dummyMemoList.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
    } else if editingStyle == .insert {
    }
  }
}

extension DiaryViewController: UITableViewDataSource{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Memo.dummyMemoList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "memoCell", for: indexPath) as! MemoListTableViewCell
    
    if let exitMemo = editMemoType {
      navigationItem.title = "메모 편집"
      cell.mainText.text = exitMemo.mainText
      cell.subText.text = formatter.string(from: exitMemo.subText)
    } else {
      let memo = Memo.dummyMemoList[indexPath.row]
      cell.mainText.text = memo.mainText
      cell.subText.text = formatter.string(from: memo.subText)
    }
    return cell
  }
}
