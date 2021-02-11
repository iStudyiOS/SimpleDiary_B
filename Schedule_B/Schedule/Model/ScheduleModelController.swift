//
//  ScheduleModelController.swift
//  Schedule_B
//
//  Created by Shin on 2/9/21.
//

import Foundation


class ScheduleModelController: ObservableObject {
    private var schedules: [Schedule]
    typealias Table = [Int: [Schedule]]
    private let dataFileName = "SimpleDiaryScheduleData.json"
    @Published private(set) var scheduleTable: Table
    
    // MARK:- CRUD
    func addNewScehdule(_ newSchedule: Schedule) {
        schedules.append(newSchedule)
        scheduleTable.add(newSchedule)
    }
    func deleteSchedule(_ scheduleToDelete: Schedule) {
        guard let indexToDelete = schedules.firstIndex(of: scheduleToDelete )else {
            fatalError("Delete fail schedule not exist:\n \(scheduleToDelete)")
        }
        schedules.remove(at: indexToDelete)
        scheduleTable.delete(scheduleToDelete)
    }
    func replaceSchedule(_ oldSchedule: Schedule, to newSchedule: Schedule) {
        deleteSchedule(oldSchedule)
        addNewScehdule(newSchedule)
    }
    
    // MARK:- Save & Load
    
    //HELPER
    
    private func saveUserFile() {
        if let fileURL = userFilePath {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(self.schedules)
                try data.write(to: fileURL)
            }catch {
                fatalError("Couln't write json data:\n \(error)")
            }
        }else {
            fatalError("Couln't get file path for saving")
        }
    }
    
    func loadFile(){
        let data: Data
        let fileURL: URL
        if boolUserFileExist {
            fileURL = userFilePath!
        }else {
            if let defaultURL = Bundle.main.url(forResource: dataFileName, withExtension: nil) {
                fileURL = defaultURL
            }else {
                fatalError("Count't get default data file")
            }
        }
        do {
            data = try Data(contentsOf: fileURL)
        }catch {
            fatalError("Couln't load \(dataFileName) from main bundle: \n \(error)")
        }
        do {
            let decoder = JSONDecoder()
            self.schedules = try decoder.decode([Schedule].self, from: data)
        } catch {
            fatalError("Couln't parse \(dataFileName): \n\(error)")
        }
        scheduleTable.update(by: schedules)
    }

    private var userFilePath: URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first else {
            return nil
        }
        return documentURL.appendingPathComponent(dataFileName)
    }
    private var boolUserFileExist: Bool {
        if let fileURL = userFilePath {
            do {
                return try fileURL.checkResourceIsReachable()
            }catch {
                return false
            }
        }else {
            return false
        }
    }
    
    init() {
        
        /*
         TEST Dummy data
         
         */
//        let date1 = DateComponents(calendar: Calendar.current,
//                                   year: 2021,
//                                   month: 2,
//                                   day: 10).date!
//        let test1 = Schedule(time: .spot(date1), priority: 2)
//        let date2 = DateComponents(calendar: Calendar.current,
//                                   year: 2021,
//                                   month: 2,
//                                   day: 10,
//                                   hour: 10).date!
//        let test2 = Schedule(time: .spot(date2), priority: 1)
//        let date3_start = DateComponents(calendar: Calendar.current,
//                                   year: 2021,
//                                   month: 2,
//                                   day: 1).date!
//        let date3_end = DateComponents(calendar: Calendar.current,
//                                   year: 2021,
//                                   month: 2,
//                                   day: 11).date!
//        let test3 = Schedule(time: .period(start: date3_start, end: date3_end), priority: 4)
//        let date4_start = DateComponents(calendar: Calendar.current,
//                                   year: 2021,
//                                   month: 2,
//                                   day: 10).date!
//        let date4_end = DateComponents(calendar: Calendar.current,
//                                   year: 2021,
//                                   month: 2,
//                                   day: 15).date!
//        let test4 = Schedule(time: .period(start: date4_start, end: date4_end), priority: 3)
        schedules = []        
        scheduleTable = Table()
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
    mutating func add(_ newSchedule: Schedule) {
        switch newSchedule.time {
        case .spot(let date):
            let key = date.toInt()
            self.append(newSchedule, to: key)
        case .period(start: let startDate, end: let endDate):
            let startKey = startDate.toInt()
            let endKey = endDate.toInt()
            let range = startKey...endKey
            for key in range {
                self.append(newSchedule, to: key)
            }
        }
    }
    mutating func delete(_ scheduleToDelete: Schedule) {
        switch scheduleToDelete.time {
        case .spot(let date):
            let key = date.toInt()
            guard let indexInTable = self[key]?.firstIndex(of: scheduleToDelete) else {
                fatalError("Delete fail schedule is not in table") }
            self[key]?.remove(at: indexInTable)
        case .period(start: let startDate, end: let endDate):
            let startKey = startDate.toInt()
            let endKey = endDate.toInt()
            let range = startKey...endKey
            for key in range {
                guard let indexInTable = self[key]?.firstIndex(of: scheduleToDelete) else {
                    fatalError("Delete fail schedule is not in table") }
                self[key]?.remove(at: indexInTable)
            }
        }
    }
    mutating func update(by schedules: [Schedule]) {
        schedules.forEach { schedule in
            switch schedule.time {
            case .spot(let date):
                let key = date.toInt()
                self.append(schedule, to: key)
            case .period(start: let startDate, end: let endDate):
                let startKey = startDate.toInt()
                let endKey = endDate.toInt()
                let range = startKey...endKey
                for key in range {
                    self.append(schedule, to: key)
                }
            }
        }
    }
}
