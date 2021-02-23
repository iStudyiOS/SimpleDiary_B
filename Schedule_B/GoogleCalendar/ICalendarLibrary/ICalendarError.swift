import Foundation

enum ICalendarError: Error {
    case fileNotFound
    case encoding
    case parseError
    case unsupportedICalVersion
}
