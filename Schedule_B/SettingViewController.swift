//
//  SettingViewController.swift
//  Schedule_B
//
//  Created by Shin on 2/17/21.
//

import UIKit
import AuthenticationServices

class SettingViewController: UITableViewController {
    // MARK:- Controller
    var scheduleModelController: ScheduleModelController!
    
    // MARK:- Properties
    @IBOutlet weak var deleteScheduleDataCell: UITableViewCell!
    @IBOutlet weak var connectGoogleCalendarCell: UITableViewCell!
    
    // MARK:- User intents
    
    @objc private func tapConnectGoogleCalendar() {
        performSegue(withIdentifier: "ConnectGoogleCalendarSegue", sender: nil)
    }
    
    @objc private func tapDeleteScheduleDataCell() {
        let alertController = UIAlertController(
            title: "스케쥴 삭제",
            message: "모든 스케쥴이 삭제됩니다",
            preferredStyle: .alert)
        alertController.addAction(
            UIAlertAction(title: "취소", style: .cancel))
        alertController.addAction(UIAlertAction(
                                    title: "지우기",
            style: .destructive) {_ in
            if !self.scheduleModelController.removeAllSchedule() {
                // Fail to remove
                let alertController = UIAlertController(title: "삭제 실패",
                 message: "유저 데이터를 지우는데 실패하였습니다",
                 preferredStyle: .alert)
                alertController.addAction(
                    UIAlertAction(title: "확인",
                                  style: .cancel))
                self.present(alertController, animated: true)
            }
        })
        present(alertController, animated: true)
    }
    // MARK:- init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if scheduleModelController == nil {
            preconditionFailure("Schedule model controller is not connected")
        }
        tableView.allowsSelection = false
        deleteScheduleDataCell.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(tapDeleteScheduleDataCell)))
        connectGoogleCalendarCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapConnectGoogleCalendar)))
    }
}
