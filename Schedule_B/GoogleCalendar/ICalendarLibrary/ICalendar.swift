import Foundation

/// TODO add documentation
struct ICalendar {
    var subComponents: [CalendarComponent] = []
    var otherAttrs = [String:String]()
    
    init(withComponents components: [CalendarComponent]?) {
        if let components = components {
            self.subComponents = components
        }
    }
    
    /// Loads the content of a given string.
    ///
    /// - Parameter string: string to load
    /// - Returns: List of containted `Calendar`s
    static func load(string: String) -> [ICalendar] {
        let icsContent = string.components(separatedBy: "\r\n")
        return parse(icsContent)
    }
    
    /// Loads the contents of a given URL. Be it from a local path or external resource.
    ///
    /// - Parameters:
    ///   - url: URL to load
    ///   - encoding: Encoding to use when reading data, defaults to UTF-8
    /// - Returns: List of contained `Calendar`s.
    /// - Throws: Error encountered during loading of URL or decoding of data.
    /// - Warning: This is a **synchronous** operation! Use `load(string:)` and fetch your data beforehand for async handling.
    static func load(url: URL, encoding: String.Encoding = .utf8) throws -> [ICalendar] {
        let data = try Data(contentsOf: url)
        guard let string = String(data: data, encoding: encoding) else { throw ICalendarError.encoding }
        return load(string: string)
    }
    
    private static func parse(_ icsContent: [String]) -> [ICalendar] {
        let parser = ICalendarParser(icsContent)
        do {
            return try parser.read()
        } catch let error {
            print(error)
            return []
        }
    }
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        return dateFormatter
    }()
}

extension ICalendar: IcsElement {
    
    mutating func append(component: CalendarComponent?) {
        guard let component = component else {
            return
        }
        self.subComponents.append(component)
    }
    
    mutating func addAttribute(attr: String, _ value: String) {
        switch attr { // TODO switch not needed, it'll always be default
        default:
            otherAttrs[attr] = value
        }
    }
    
}

extension ICalendar: CalendarComponent {
    func toCal() -> String {
        var str = "BEGIN:VCALENDAR\n"
        
        for (key, val) in otherAttrs {
            str += "\(key):\(val)\n"
        }
        
        for component in subComponents {
            str += "\(component.toCal())\n"
        }
        
        str += "END:VCALENDAR"
        return str
    }
}
