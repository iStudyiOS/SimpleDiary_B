
import Foundation
import Combine

class ScheduleModelController: ObservableObject {
    
    /**
     Data intergrity
     - Warning: Do not modify directly
     
     - TODO:  Change array to set ?
     */
    @Published private var schedules: [Schedule]
    typealias Table = [Int: [Schedule]]
    @Published private(set) var scheduleTable: Table
    @Published private(set) var cycleTable: CycleTable
    private(set) var holidayTable: [Int: HolidayGather.Holiday]
    private(set) var userSetting = Setting(country: .korea)
    lazy var notificationContoller = NotificationController()
    
    // MARK:- CRUD
    
    func getSchedules(for dateInt: Int) -> [Schedule] {
        var schedulesForDay = [Schedule]()
        if let atDate = scheduleTable[dateInt]{
            schedulesForDay += atDate
        }
        let date = dateInt.toDate!
        if let weekdayCycle = cycleTable.weekday[date.weekDay] {
            schedulesForDay += weekdayCycle.filter() {
                switch $0.time {
                case .cycle(since: let startDate, _, _):
                    return date > startDate
                default :
                    return false
                }
            }
        }
        if let dayCycle = cycleTable.day[date.day] {
            schedulesForDay += dayCycle.filter(){
                switch $0.time {
                case .cycle(since: let startDate, _, _):
                    return date > startDate
                default :
                    return false
                }
            }
        }
        return schedulesForDay
    }
    /// Add new schedule
    /// - Note: Check permission in notification controller before add alarm
    /// - Returns: Boolean value return false when try to add  alarm without permission
    func addNewSchedule(_ newSchedule: Schedule) -> Bool{
        if newSchedule.alarm != nil {
            if notificationContoller.authorizationStatus == .authorized {
                notificationContoller.setAlarm(of: newSchedule)
            }else {
                return false
            }
        }
        schedules.append(newSchedule)
        enrollToTable(newSchedule)
        return true
    }
    func deleteSchedule(_ scheduleToDelete: Schedule) {
        guard let indexToDelete = schedules.firstIndex(of: scheduleToDelete )else {
            fatalError("Delete fail schedule not exist:\n \(scheduleToDelete)")
        }
        schedules.remove(at: indexToDelete)
        scheduleTable.delete(scheduleToDelete)
        if scheduleToDelete.alarm != nil {
            notificationContoller.removeAlarm(of: scheduleToDelete)
        }
    }
    func replaceSchedule(_ oldSchedule: Schedule, to newSchedule: Schedule) -> Bool {
        deleteSchedule(oldSchedule)
        return addNewSchedule(newSchedule)
    }
    private func enrollToTable(_ schedule: Schedule) {
        switch schedule.time {
        case .spot(let date):
            let key = date.toInt
            scheduleTable.append(schedule, to: key)
        case .period(start: let startDate, end: let endDate):
            let startKey = startDate.toInt
            let endKey = endDate.toInt
            let range = startKey...endKey
            for key in range {
                scheduleTable.append(schedule, to: key)
            }
        case .cycle(_, for: let factor, every: let values):
            switch factor {
            case .day:
                for day in values {
                    cycleTable.day.append(schedule, to: day)
                }
            case .weekday:
                for weekday in values {
                    cycleTable.weekday.append(schedule, to: weekday)
                }
            }
        }
    }
    
    func importSchedules(_ schedulesToImport:[Schedule]) -> Bool {
        var isEveryScheduleAdded = true
        schedulesToImport.forEach { scheduleToImport in
            if let duplicatedSchedule = schedules.first(
                where: { $0.location == scheduleToImport.location })
            {
                deleteSchedule(duplicatedSchedule)
            }
            if !addNewSchedule(scheduleToImport) {
                isEveryScheduleAdded = false
                print("Attemp to import schedule without notification authoriazation \n \(scheduleToImport)")
            }
        }
        return isEveryScheduleAdded
    }
    
    // MARK:- Save & Load
    private let userdataFileName = "user_schedule_data"
    private var autoSaveCancellable: AnyCancellable?
    
    func retrieveUserData() {
        if let fileData = loadFile(filename: userdataFileName, as: [Schedule].self) {
            schedules = fileData
            schedules.forEach() { enrollToTable($0) }
            autoSaveCancellable = $schedules.sink(receiveValue: { [self] changedSchedules in
                let encoder = JSONEncoder()
                if let data = try? encoder.encode(changedSchedules){
                    saveFile(data: data, filename:  userdataFileName)
                }else {
                    print("save failed")
                }
            })
        }else {
            print("load failed")
            autoSaveCancellable = $schedules.sink(receiveValue: { [self] changedSchedule in
                let encoder = JSONEncoder()
                if let data = try? encoder.encode(changedSchedule){
                    saveFile(data: data, filename:  userdataFileName)
                }
            })
        }
        
    }
    func checkHolidayData(for year: Int, about country: HolidayGather.CountryCode) {
        let fileName = "holiday_data" + "_\(country.rawValue)" + "(\(year))"
        
        if checkFileExist(for: fileName) {
            let JSONData = loadFile(
                filename: fileName,
                as: HolidayGather.Response.self)
            if JSONData == nil, JSONData!.meta["code"] != 200 {
                print("Holiday data from server is not valid")
                return
            }
            let holidayData = JSONData!.response.holidays
            holidayData.forEach() {
                let holiday = HolidayGather.Holiday(from: $0)
                holidayTable[holiday.dateInt] = holiday
            }
        }else {
            let holidayGather = HolidayGather()
            holidayGather.retrieveHolidays(
                about: year, of: country){ [weak weakSelf = self] data in
                weakSelf?.saveFile(data: data, filename: fileName)
                weakSelf?.checkHolidayData(for: year,
                                           about: country)
            }
        }
    }
    
    private func saveFile(data: Data, filename: String) {
        if let fileURL = getFilePath(for: filename) {
            do {
                try data.write(to: fileURL, options: .atomic)
            }catch {
                fatalError("Couln't write json data to \(filename):\n \(error)")
            }
        }else {
            fatalError("Couln't get file path for saving: \(filename)")
        }
    }
    
    private func loadFile<T: Codable>(filename: String, as returnType: T.Type) -> T? {
        let data: Data
        let fileURL: URL
        if checkFileExist(for: filename) {
            fileURL = getFilePath(for: filename)!
        }else {
            return nil
        }
        do {
            data = try Data(contentsOf: fileURL)
        }catch {
            fatalError("Couln't load \(filename) from \(fileURL.path): \n \(error)")
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couln't parse \(filename): \n\(error)")
        }
    }
    private func getFilePath(for fileName: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first else {
            return nil
        }
        return documentURL.appendingPathComponent(fileName).appendingPathExtension("json")
    }
    private func checkFileExist(for fileName: String) -> Bool {
        if let fileURL = getFilePath(for: fileName) {
            do {
                return try fileURL.checkResourceIsReachable()
            }catch {
                return false
            }
        }else {
            return false
        }
    }
    /// Remove all schedule, saved date will be deleted
    func removeAllSchedule() -> Bool{
        schedules.removeAll()
        scheduleTable.removeAll()
        cycleTable.day.removeAll()
        cycleTable.weekday.removeAll()
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(schedules){
            saveFile(data: data, filename: userdataFileName)
            return true
        }else {
            return false
        }
    }
    
    struct CycleTable {
        fileprivate(set) var weekday: Table
        fileprivate(set) var day: Table
    }
    struct Setting {
        var country: HolidayGather.CountryCode
    }
    
    init() {
        schedules = []
        scheduleTable = Table()
        cycleTable = CycleTable(weekday: Table(), day: Table())
        holidayTable = [Int: HolidayGather.Holiday]()
    }
}

extension Dictionary where Key == Int, Value == [Schedule] {
    mutating func append(_ value: Schedule, to key: Int) {
        if self[key] == nil{
            self[key] = [Schedule]()
            self[key]?.append(value)
        }else {
            self[key]?.append(value)
        }
    }
    mutating func delete(_ scheduleToDelete: Schedule) {
        switch scheduleToDelete.time {
        case .spot(let date):
            let key = date.toInt
            guard let indexInTable = self[key]?.firstIndex(of: scheduleToDelete) else {
                fatalError("Delete fail schedule is not in table \n \(scheduleToDelete)") }
            self[key]?.remove(at: indexInTable)
        case .period(start: let startDate, end: let endDate):
            let startKey = startDate.toInt
            let endKey = endDate.toInt
            let range = startKey...endKey
            for key in range {
                guard let indexInTable = self[key]?.firstIndex(of: scheduleToDelete) else {
                    fatalError("Delete fail schedule is not in table \n \(scheduleToDelete)") }
                self[key]?.remove(at: indexInTable)
            }
        case .cycle(_, _, every: let values):
            for key in values {
                guard let indexInTable = self[key]?.firstIndex(of: scheduleToDelete) else {
                    fatalError("Delete fail schedule is not in table \n \(scheduleToDelete)") }
                self[key]?.remove(at: indexInTable)
            }
        }
    }
}
