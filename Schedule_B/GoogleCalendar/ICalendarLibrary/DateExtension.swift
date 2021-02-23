import Foundation

extension Date {
    /// Convert String to Date
    func toIcalendarString() -> String {
        return ICalendar.dateFormatter.string(from: self)
    }
}
