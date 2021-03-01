//
//  EventListCell.swift
//  Schedule_B
//
//  Created by Shin on 2/24/21.
//

import UIKit

class EventListCell: UITableViewCell {
    
    // MARK: Properites
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var alarmButton: UIButton!
    @IBAction func tapAlarmButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.imageView?.tintColor = sender.isSelected ? .systemPink : .darkGray
        turnAlarm?(eventPresented!.id, sender.isSelected)
    }
    
    var eventPresented: Schedule?
    var turnAlarm: ((UUID, Bool) -> Void)?
}
