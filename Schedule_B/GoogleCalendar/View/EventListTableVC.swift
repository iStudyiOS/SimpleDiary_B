//
//  EventListTableVC.swift
//  Schedule_B
//
//  Created by Shin on 2/24/21.
//

import UIKit

class EventListTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    var eventListTableView: UITableView!
    /// Do not set to nil
    var events: [Schedule]? {
        didSet {
            selectedEventID.removeAll()
            events!.forEach {
                if case let .googleCalendar(_, newID) = $0.location{
                    selectedEventID.insert(newID)
                }
            }
            DispatchQueue.runOnlyMainThread { [ weak weakSelf = self] in
                weakSelf?.eventListTableView.reloadData()
            }
        }
    }
    private var selectedEventID = Set<String>()
    var schedulesToImport: [Schedule] {
        return events!.filter {
            if case let .googleCalendar(_, eventID) = $0.location {
                return selectedEventID.contains(eventID)
            }else {
                return false
            }
        }
    }
    
    // MARK:- User intents
    func changeGroupInclusion(to isIncluded: Bool) {
        if isIncluded {
            events!.forEach {
                if case let .googleCalendar(_, newID) = $0.location{
                    selectedEventID.insert(newID)
                }
            }
        }else {
            selectedEventID.removeAll()
        }
        eventListTableView.reloadData()
    }
    
    // MARK:- Table view delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        events?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = eventListTableView.dequeueReusableCell(withIdentifier: "eventList") as! EventListCell
        guard events != nil else { return cell }
        cell.eventPresented = events![indexPath.row]
        // Title label
        cell.titleLabel.text = cell.eventPresented!.title
        // Date Label
        switch cell.eventPresented!.time {
        case .spot(let date):
            cell.dateLabel.text = date.shortString
        case .period(start: let startDate, end: _):
            cell.dateLabel.text = startDate.shortString
        default:
            break
        }
        if cell.eventPresented?.alarm != nil {
            cell.alarmButton.isHidden = false
            cell.alarmButton.isSelected = cell.eventPresented!.isAlarmOn
            cell.turnAlarm = { [weak weakSelf = self]scheduleID, isOn in
                if let eventIndex = weakSelf?.events?.firstIndex(
                    where: { $0.id == scheduleID })
                {
                    self.events![eventIndex].isAlarmOn = isOn
                }
            }
        }else {
            cell.alarmButton.isHidden = true
        }
        if case let .googleCalendar(_, eventID) = cell.eventPresented!.location{
            cell.accessoryType = selectedEventID.contains(eventID) ? .checkmark : .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if case let .googleCalendar(_, eventID) = events![indexPath.row].location
        {
            if selectedEventID.contains(eventID){
                selectedEventID.remove(eventID)
            }else {
                selectedEventID.insert(eventID)
            }
            eventListTableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if let eventListCell = cell as? EventListCell,
//           case let .googleCalendar(_, eventID) = eventListCell.eventPresented?.location{
//            cell.accessoryType = selectedEventID.contains(eventID) ? .checkmark : .none
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
