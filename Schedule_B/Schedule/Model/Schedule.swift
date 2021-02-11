
import Foundation


struct Schedule: Codable, Identifiable, Comparable {
    //Test dummy data
    var title = "dummy title"
    var description = "dummy description"
    //
    var time: DateType
    var priority: Int
    var id = UUID()
    
    enum DateType: Codable {
        case spot (Date)
        case period (start: Date, end: Date)
    }
    
    static func == (lhs: Schedule, rhs: Schedule) -> Bool {
            lhs.id == rhs.id
    }
    
    static func < (lhs: Schedule, rhs: Schedule) -> Bool {
        switch (lhs.time, rhs.time) {
        case(let .spot(dateLhs), let .spot(dateRhs)):
            return dateLhs < dateRhs
        case (let .spot(dateLhs), let .period(startRhs, _)):
            return dateLhs < startRhs
        case (let .period(startLhs, _), let .period(startRhs, _)):
            return startLhs < startRhs
        case (let .period(startLhs, _), let .spot(dateRhs)):
            return startLhs < dateRhs
        }
    }
}


//Encode to JSON
extension Schedule.DateType {

    private enum CodingKeys: String, CodingKey {
        case spot
        case start
        case end
        case type
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
            fatalError("Invalid Date type of schdule during decoding")
        }
    }
}
