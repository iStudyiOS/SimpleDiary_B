import Foundation

/// TODO add documentation
struct ICalendarEvent: Loopable {
     var subComponents: [CalendarComponent] = []
     var otherAttrs = [String:String]()

    // required
     var uid: String!
     var dtstamp: Date!

    // optional
    //  var organizer: Organizer? = nil
     var location: String?
     var summary: String?
     var descr: String?
    //  var class: some enum type?
     var dtstart: Date?
     var dtend: Date?

     init(uid: String? = NSUUID().uuidString, dtstamp: Date? = Date()) {
        self.uid = uid
        self.dtstamp = dtstamp
    }
}

extension ICalendarEvent: CalendarComponent {
     func toCal() -> String {
        var str: String = "BEGIN:VEVENT\n"

        if let uid = uid {
            str += "UID:\(uid)\n"
        }
        if let dtstamp = dtstamp {
            str += "DTSTAMP:\(dtstamp.toIcalendarString())\n"
        }
        if let summary = summary {
            str += "SUMMARY:\(summary)\n"
        }
        if let descr = descr {
            str += "DESCRIPTION:\(descr)\n"
        }
        if let dtstart = dtstart {
            str += "DTSTART:\(dtstart.toIcalendarString())\n"
        }
        if let dtend = dtend {
            str += "DTEND:\(dtend.toIcalendarString())\n"
        }

        for (key, val) in otherAttrs {
            str += "\(key):\(val)\n"
        }

        for component in subComponents {
            str += "\(component.toCal())\n"
        }

        str += "END:VEVENT"
        return str
    }
}

extension ICalendarEvent: IcsElement {
     mutating func addAttribute(attr: String, _ value: String) {
        switch attr {
        case "UID":
            uid = value
        case "DTSTAMP":
            dtstamp = value.toICalendarDate()
        case "DTSTART":
            dtstart = value.toICalendarDate()
        case "DTEND":
            dtend = value.toICalendarDate()
        // case "ORGANIZER":
        //     organizer
        case "SUMMARY":
            summary = value
        case "DESCRIPTION":
            descr = value
        default:
            otherAttrs[attr] = value
        }
    }
}

extension ICalendarEvent: Equatable { }

 func ==(lhs: ICalendarEvent, rhs: ICalendarEvent) -> Bool {
    return lhs.uid == rhs.uid
}

extension ICalendarEvent: CustomStringConvertible {
     var description: String {
        return "\(dtstamp.toIcalendarString()): \(summary ?? "")"
    }
}
