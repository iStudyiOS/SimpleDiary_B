
import Foundation

extension Calendar {
    static func getDaysInMonth(_ monthAndYear: Int) -> Int {
        let firstDate = firstDateOfMonth(monthAndYear)
        let range = Calendar.current.range(
            of: .day,
            in: .month,
            for: firstDate)
        return range!.count
    }
    static func firstDateOfMonth(_ monthAndYear: Int) -> Date {
        return DateComponents(calendar: Calendar.current,
                                         timeZone: .current,
                                         year: monthAndYear / 100,
                                         month: monthAndYear % 100).date!    }

    static func firstDateOfMonth(date: Date) -> Date {
        let start = DateComponents(calendar: Calendar.current, timeZone: .current, year: date.year, month: date.month)
        return Calendar.current.date(from: start)!
    }
    static func lastDateOfMonth(date: Date) -> Date {
         let nextMonthFirstDate = DateComponents(calendar: Calendar.current, timeZone: .current, year: date.year, month: date.month + 1).date!
        return Calendar.current.date(byAdding: .day, value: -1, to: nextMonthFirstDate)!
    }
}


extension Date {
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
        Calendar.current.component(.weekday, from: self) - 1
    }
    static func aMonthAgo(from date: Date) -> Date {
        return Calendar.current.date(
            byAdding: DateComponents(month: -1), to: date)!
    }
    static func aMonthAfter(from date: Date) -> Date {
        return Calendar.current.date(
            byAdding: DateComponents(month: 1), to: date)!
    }
    func isSameDay(with toCompare: Date) -> Bool {
        return self.year == toCompare.year && self.month == toCompare.month && self.day == toCompare.day
    }
    func toInt() -> Int {
        return (self.year * 10000) + (self.month * 100) + self.day
    }
}

extension Int {
    func toDate() -> Date?{
        return DateComponents(calendar: Calendar.current,
                              timeZone: .current,
                              year: self / 10000,
                              month: (self / 100) % 100,
                              day: self % 100).date!
    }
}
