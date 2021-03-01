
import Foundation

extension Calendar {
    static func getDaysInMonth(_ yearAndMonth: Int) -> Int {
        let firstDate = firstDateOfMonth(yearAndMonth)
        let range = Calendar.current.range(
            of: .day,
            in: .month,
            for: firstDate)
        return range!.count
    }
    static func firstDateOfMonth(_ yearAndMonth: Int) -> Date {
        return DateComponents(
            calendar: Calendar.current,
            timeZone: .current,
            year: yearAndMonth / 100,
            month: yearAndMonth % 100).date!
    }
}

extension Date: Strideable {
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

    var year: Int {
        Calendar.current.component(.year, from: self)
    }
    var month: Int {
        Calendar.current.component(.month, from: self)
    }
    var day: Int {
        Calendar.current.component(.day, from: self)
    }
    var weekDay: Int {
        Calendar.current.component(.weekday, from: self)
    }
    var weekDayString: String {
        switch self.weekDay {
        case 1:
            return "SUN"
        case 2:
            return "MON"
        case 3:
            return "TUE"
        case 4:
            return "WED"
        case 5:
            return "THUR"
        case 6:
            return "FRI"
        case 7:
            return "SAT"
        default:
            return ""
        }
    }
    var hour: Int {
        Calendar.current.component(.hour, from: self)
    }
    var minute: Int {
        Calendar.current.component(.minute, from: self)
    }
    /// String literal ( e.g. 21.02.03)
    var shortString: String{
        let dateFomatter = DateFormatter()
        dateFomatter.dateStyle = .short
        dateFomatter.locale = Locale(identifier: "ko_kr")
        dateFomatter.timeStyle = .none
        return dateFomatter.string(from: self)
    }
    var koreanString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko")
        dateFormatter.dateFormat = "MMM d일"
        return dateFormatter.string(from: self)
    }
    
    var aMonthAgo: Date {
        return Calendar.current.date(
            byAdding: DateComponents(month: -1), to: self)!
    }
    var aMonthAfter: Date {
        return Calendar.current.date(
            byAdding: DateComponents(month: 1), to: self)!
    }
    func isSameDay(with toCompare: Date) -> Bool {
        return self.year == toCompare.year && self.month == toCompare.month && self.day == toCompare.day
    }
    var toInt: Int {
        return (self.year * 10000) + (self.month * 100) + self.day
    }
    var startOfDay: Date {
        let components = Calendar.current.dateComponents([.year, .month, .day],
                                        from: self)
        return Calendar.current.date(from: components)!
    }
    func getNext(by component: ComponentType) -> Date{
        var nextComponent = Calendar.current.dateComponents([.hour, .minute], from: self)
        
        switch component {
        case .day(let day):
            nextComponent.day = day
        case .weekday(let weekday):
            nextComponent.weekday = weekday
        }
        
        return Calendar.current.nextDate(
            after: self,
            matching: nextComponent,
            matchingPolicy: .nextTime)!
    }
    enum ComponentType {
        case day (Int)
        case weekday (Int)
    }
}

extension Int {
    var toDate: Date?{
        DateComponents(
            calendar: Calendar.current,
            timeZone: .current,
            year: self / 10000,
            month: (self / 100) % 100,
            day: self % 100).date
    }
}

extension TimeInterval {
    static var forOneDay: TimeInterval {
        TimeInterval(60 * 60 * 24)
    }
}
