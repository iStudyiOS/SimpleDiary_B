import Foundation

/// TODO add documentation
class ICalendarParser {
    let icsContent: [String]

    init(_ ics: [String]) {
        icsContent = ics
    }

    func read() throws -> [ICalendar] {
        var completeCal = [ICalendar?]()

        // Such state, much wow
        var inCalendar = false
        var currentCalendar: ICalendar?
        var inEvent = false
        var currentEvent: ICalendarEvent?
        var inAlarm = false
        var currentAlarm: ICalendarAlarm?

        for (_ , line) in icsContent.enumerated() {
            switch line {
            case "BEGIN:VCALENDAR":
                inCalendar = true
                currentCalendar = ICalendar(withComponents: nil)
                continue
            case "END:VCALENDAR":
                inCalendar = false
                completeCal.append(currentCalendar)
                currentCalendar = nil
                continue
            case "BEGIN:VEVENT":
                inEvent = true
                currentEvent = ICalendarEvent()
                continue
            case "END:VEVENT":
                inEvent = false
                currentCalendar?.append(component: currentEvent)
                currentEvent = nil
                continue
            case "BEGIN:VALARM":
                inAlarm = true
                currentAlarm = ICalendarAlarm()
                continue
            case "END:VALARM":
                inAlarm = false
                currentEvent?.append(component: currentAlarm)
                currentAlarm = nil
                continue
            default:
                break
            }

            guard let (key, value) = line.toKeyValuePair(splittingOn: ":") else {
//                 print("(key, value) is nil") // DEBUG
                continue
            }

            if inCalendar && !inEvent {
                currentCalendar?.addAttribute(attr: key, value)
            }

            if inEvent && !inAlarm {
                currentEvent?.addAttribute(attr: key, value)
            }

            if inAlarm {
                currentAlarm?.addAttribute(attr: key, value)
            }
        }

        return completeCal.compactMap{ $0 }
    }
}
