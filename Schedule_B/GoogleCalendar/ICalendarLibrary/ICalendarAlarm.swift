import Foundation

/// TODO add documentation
 struct ICalendarAlarm {
     var subComponents: [CalendarComponent] = []
     var otherAttrs = [String:String]()
}

extension ICalendarAlarm: IcsElement {
     mutating func addAttribute(attr: String, _ value: String) {
        switch attr { // TODO switch not needed, it'll always be default
            default:
                otherAttrs[attr] = value
        }
    }
}

extension ICalendarAlarm: CalendarComponent {
     func toCal() -> String {
        var str = "BEGIN:VALARM\n"

        for (key, val) in otherAttrs {
            str += "\(key):\(val)\n"
        }

        str += "END:VALARM"
        return str
    }
}
