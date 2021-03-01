

import Foundation

struct Schedule: Codable, Identifiable, Comparable {
    
    let title: String
    let description: String
    let time: DateType
    let alarm: Alarm?
    var isAlarmOn: Bool
    let priority: Int
    var isDone = false
    let location: Location
    private(set) var id = UUID()
    
    var idForNotification: String {
        "ScheduleNotification:" + id.uuidString
    }
    enum DateType: Codable {
        case spot (Date)
        case cycle (since: Date, for: CycleFactor, every: [Int])
        case period (start: Date, end: Date)
    }
    enum CycleFactor: String, Codable{
        case weekday = "weekday"
        case day = "day"
    }
    
    enum Alarm: Equatable, Codable{
        case once (Date)
        case periodic (Date)
    }
    
    enum Location: Codable, Equatable {
        case localDevice
        case googleCalendar(calendarID: String, uid: String)
    }
    
    static func == (lhs: Schedule, rhs: Schedule) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: Schedule, rhs: Schedule) -> Bool {
        let criterion: (Date, Date)
        switch (lhs.time, rhs.time) {
        case(let .spot(dateLhs), let .spot(dateRhs)):
            criterion = (dateLhs, dateRhs)
        case (let .spot(dateLhs), let .period(startRhs, _)):
            criterion = (dateLhs, startRhs)
        case (let .spot(dateLhs), let .cycle(sinceRhs, _, _)):
            criterion = (dateLhs, sinceRhs)
        case (let .period(startLhs, _), let .period(startRhs, _)):
            criterion = (startLhs, startRhs)
        case (let .period(startLhs, _), let .spot(dateRhs)):
            criterion = (startLhs, dateRhs)
        case (let .period(startLhs, _), let .cycle(sinceRhs, _, _)):
            criterion = (startLhs, sinceRhs)
        case (let .cycle(sinceLhs, _, _), let .cycle(sinceRhs, _, _)):
            criterion = (sinceLhs, sinceRhs)
        case (let .cycle(sinceLhs, _, _), let .spot(dateRhs)):
            criterion = (sinceLhs, dateRhs)
        case (let .cycle(sinceLhs, _, _), let .period(startRhs, _)):
            criterion = (sinceLhs, startRhs)
        }
        return criterion.0 < criterion.1
    }
    init(title: String, description: String, priority: Int, time: DateType, alarm: Alarm?, storeAt location: Location = .localDevice){
        self.title = title
        self.description = description
        self.priority = priority
        self.time = time
        if alarm != nil {
            if case .periodic(_) = alarm! {
                guard case .cycle = time else {
                    fatalError("Invalid periodic alarm for non-cycle schedule")
                }
            }
        }
        self.alarm = alarm
        self.location = location
        self.isAlarmOn = alarm != nil
    }
}

//Encode to JSON
extension Schedule.DateType {
    
    private enum CodingKeys: String, CodingKey {
        case spot
        case start
        case end
        case type
        case cycleFactor
        case cycleValues
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
        case .cycle(since: let start, for: let cycleType, every: let values):
            try container.encode("cycle", forKey: .type)
            try container.encode(start, forKey: .start)
            try container.encode(cycleType.rawValue, forKey: .cycleFactor)
            try container.encode(values, forKey: .cycleValues)
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
        case "cycle":
            let start = try container.decode(Date.self, forKey: .start)
            let cycleType = try container.decode(Schedule.CycleFactor.self, forKey: .cycleFactor)
            let values = try container.decode([Int].self, forKey: .cycleValues)
            self = .cycle(since: start, for: cycleType, every: values)
        default:
            fatalError("Invalid Date type of schdule during decoding")
        }
    }
}

extension Schedule.Alarm{
    private enum CodingKeys: String, CodingKey {
        case type
        case date
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .once(let dateToAlarm):
            try container.encode("once", forKey: .type)
            try container.encode(dateToAlarm, forKey: .date)
        case .periodic(let dateToAlarm):
            try container.encode("periodic", forKey: .type)
            try container.encode(dateToAlarm, forKey: .date)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(String.self, forKey: .type)
        if type == "periodic" {
            let dateToAlarm = try container.decode(Date.self, forKey: .date)
            self = .periodic(dateToAlarm)
        } else {
            let dateToAlarm = try container.decode(Date.self, forKey: .date)
            self = .once(dateToAlarm)
        }
    }
}

extension Schedule.Location {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case location
        case calendarID
        case uid
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .localDevice:
            try container.encode("localDevice", forKey: .location)
        case .googleCalendar(let calendarID, let uid):
            try container.encode("googleCalendar", forKey: .location)
            try container.encode(calendarID, forKey: .calendarID)
            try container.encode(uid, forKey: .uid)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let location = try container.decode(String.self, forKey: .location)
        if location == "localDevice" {
            self = .localDevice
        }else if location == "googleCalendar" {
            let calendarID = try container.decode(String.self, forKey: .calendarID)
            let uid = try container.decode(String.self, forKey: .uid)
            self = .googleCalendar(calendarID: calendarID, uid: uid)
        }else {
            print(location)
            throw DecodingError.keyNotFound(
                CodingKeys.location,
                DecodingError.Context(codingPath: CodingKeys.allCases, debugDescription: "Location of schedule stored is wrong"))
        }
    }
}
