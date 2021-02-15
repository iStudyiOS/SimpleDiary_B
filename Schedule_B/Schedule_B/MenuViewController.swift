//
//  MenuViewController.swift
//  Schedule_B
//
//  Created by KEEN on 2021/02/09.
//

import UIKit

class MenuViewController: UIViewController {
  
  var menuList: [String] = ["📘다이어리 캘린더", "📕스케쥴 캘린더"]
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.rowHeight = CGFloat(60)
  }
  
}

extension MenuViewController: UITableViewDelegate {
}

extension MenuViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return menuList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let identifier: String
    switch indexPath.row {
    case 0: identifier = "MenuDiaryCell"
    case 1: identifier = "MenuScheduleCell"
    default: identifier = "MenuDiaryCell"
    }
    
    let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MenuTableViewCell
    
    cell.menuButton.layer.cornerRadius = CGFloat(10)
    cell.menuButton.setTitle("\(menuList[indexPath.row])", for: .normal)
    return cell
  }
}
