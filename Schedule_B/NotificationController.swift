
import UserNotifications

class NotificationController {
    
    private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    func setAlarm(of newSchedule: Schedule, numberOfRepeatForEach: Int = 5)  {
        guard let alarm = newSchedule.alarm else {
            fatalError("Try to set alarm not existing \n \(newSchedule)")
        }
        var datesToAlarm = [Date]()
        
        switch alarm {
        case .once(let date):
            datesToAlarm.append(date)
        case .periodic(let startDate):
            if case .cycle(_, let factor, let values) = newSchedule.time {
                switch factor {
                case .weekday:
                    for weekday in values {
                        var dateToAlarm = startDate.getNext(by: .weekday(weekday))
                        datesToAlarm.append(dateToAlarm)
                        for _ in 0..<numberOfRepeatForEach {
                            dateToAlarm = dateToAlarm.getNext(by: .weekday(weekday))
                            datesToAlarm.append(dateToAlarm)
                        }
                    }
                case .day:
                    for day in values {
                        var dateToAlarm = startDate.getNext(by: .day(day))
                        datesToAlarm.append(dateToAlarm)
                        for _ in 0..<numberOfRepeatForEach {
                            dateToAlarm = dateToAlarm.getNext(by: .day(day))
                            datesToAlarm.append(dateToAlarm)
                        }
                    }
                }
            } else {
                fatalError("Try to set periodic alarm of non-cycle schedule \n \(newSchedule)")
            }
        }
        addAlarm(foreach: datesToAlarm, of: newSchedule)
    }
    
    func removeAlarm(of schedule: Schedule) {
        guard schedule.alarm != nil else {
            fatalError("Try to remove alarm for schedule has not alarm \n \(schedule)")
        }
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { notifications in
            var identifiersToRemove = [String]()
            
            for notification in notifications {
                if notification.identifier.hasPrefix(schedule.idForNotification) {
                    identifiersToRemove.append(notification.identifier)
                }
            }
            center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
    }
    
    func requestPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if error != nil {
                print("Fail to request notification authorization \n \(error!.localizedDescription)")
                return
            }
            
            if granted {
                self.authorizationStatus = .authorized
            }else {
                self.authorizationStatus = .denied
            }
        }
    }
    func addAlarm(foreach dates: [Date], of schedule: Schedule) {
        // Check permission
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = schedule.title
        content.body = schedule.description
        var distinguisher = 0
        
        for timeToNotify in dates {
            let dateComponents = DateComponents(
                calendar: .current,
                timeZone: .current,
                year: timeToNotify.year,
                month: timeToNotify.month,
                day: timeToNotify.day,
                hour: timeToNotify.hour,
                minute: timeToNotify.minute)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(
                identifier: schedule.idForNotification + String(distinguisher),
                content: content,
                trigger: trigger)
            distinguisher += 1
            center.add(request){ error in
                if error != nil {
                    print("Error with request notification: \(error!.localizedDescription)")
                }
            }
        }
    }
    
    init() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            self.authorizationStatus = settings.authorizationStatus
        }
    }
}

