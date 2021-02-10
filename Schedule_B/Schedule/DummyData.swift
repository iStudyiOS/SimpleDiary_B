
import Foundation


struct Schedule: Codable {
    var time: DateType
    var priority: Int
    var title = "dummy title"
    var description = "dummy description"
    
    enum DateType: Codable {
        case spot (Date)
        case period (start: Date, end: Date)
    }

}
class UserData {
    private(set) var schedules: [Schedule]
    
    init() {
        let date1 = DateComponents(calendar: Calendar.current,
                                   year: 2021,
                                   month: 2,
                                   day: 20).date!
        let test1 = Schedule(time: .spot(date1), priority: 1)
        let date2 = DateComponents(calendar: Calendar.current,
                                   year: 2021,
                                   month: 2,
                                   day: 10,
                                   hour: 10).date!
        let test2 = Schedule(time: .spot(date2), priority: 2)
        let date3_start = DateComponents(calendar: Calendar.current,
                                   year: 2021,
                                   month: 2,
                                   day: 1).date!
        let date3_end = DateComponents(calendar: Calendar.current,
                                   year: 2021,
                                   month: 2,
                                   day: 5).date!
        let test3 = Schedule(time: .period(start: date3_start, end: date3_end), priority: 4)
        schedules = [test1, test2, test3]
    }
}



extension Schedule.DateType {

    private enum CodingKeys: String, CodingKey {
        case spot
        case start
        case end
        case type
    }

    enum DateTypeCodingError: Error {
        case decoding(String)
    }

    func encode(to encoder: Encoder) throws {
        //access the keyed container
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        //iterate over self and encode (1) the status and (2) the associated value(s)
        switch self {
        case .spot(let date):
            try container.encode("spot", forKey: .type)
            try container.encode(date, forKey: .spot)
        case .period(start: let start, end: let end):
            try container.encode("period", forKey: .type)
            try container.encode(start, forKey: .start)
            try container.encode(end, forKey: .end)
        }
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "spot":
            let time = try container.decode(Date.self, forKey: .spot)
            self = .spot(time)
        case "period":
            let start = try container.decode(Date.self, forKey: .start)
            let end = try container.decode(Date.self, forKey: .end)
            self = .period(start: start, end: end)
        default:
            fatalError("Invalid Date type during decoding")
        }
        
    }
}
