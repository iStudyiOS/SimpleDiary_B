

import SwiftUI

struct CalendarCellView: View {
    var date: Date?
    var isToday: Bool {
        date!.isSameDay(with: Date())
    }
    var schedules = [Schedule]()
    var searchRequest: SingleCalendarViewController.SearchRequest?
    var holiday: HolidayGather.Holiday?
    private var filteredSchedules: Array<Schedule>.SubSequence {
        let filtered = schedules.filter() {
            if let search = searchRequest {
                if search.priority != nil, search.priority != $0.priority{
                    return false
                }
                if search.text != nil{
                    return $0.title.lowercased().contains(search.text!) || $0.description.lowercased().contains(search.text!)
                }else {
                    return true
                }
            }else {
                return true
            }
        }
    
        return filtered.sortedByPriority.prefix(3)
    }
    private var dateFontColor: Color {
        if holiday != nil {
            if date!.weekDay == 1 || holiday!.type == .national {
                return Color.red
            }else if date!.weekDay == 7 {
                return Color.blue
            }else {
                return Color.gray
            }
        }else {
            return Color.forDate(date!)
        }
    }
    
    var body: some View {
        if date != nil {
            GeometryReader{ geometry in
                
                VStack{
                    Text(String(date!.day))
                        .font(.body)
                        .overlay(isToday ? RoundedRectangle(
                                    cornerRadius: 10)
                                    .stroke(Color.red.opacity(0.8),
                                            lineWidth: 2.5)
                                    : nil)
                    if holiday != nil{
                        Text(holiday!.title)
                            .font(.system(size: 10))
                            .lineLimit(1)
                    }
                }
                .foregroundColor(dateFontColor)
                .position(x: geometry.size.width / 2,
                          y: geometry.size.height * 0.15)
                .frame(maxHeight: geometry.size.height * 0.2)
                Rectangle()
                    .frame(width: geometry.size.width * 1.1,
                           height: 2)
                    .position(x: geometry.size.width / 2 ,
                              y: geometry.size.height * 0.3)
                    .foregroundColor(dateFontColor.opacity(0.5))
                
                VStack(alignment: .leading){
                    ForEach(filteredSchedules, id:\.id) { schedule in
                        HStack{
                            RoundedRectangle(cornerRadius: 10, style: .circular)
                                .inset(by: CGFloat(4.5 - Double(schedules.count)))
                                .fill(Color.byPriority(schedule.priority))
                                .aspectRatio(0.3, contentMode: .fit)
                            Text(schedule.title)
                                .font(.system(size: 10))
                                .lineLimit(1)
                                .foregroundColor(Color.byPriority(schedule.priority))
                                .padding(.leading, -5)
                        }
                        .frame(width: geometry.size.width,
                               height:
                                (geometry.size.height * 0.7) / CGFloat(schedules.count + 1),
                               alignment: .leading)
                    }
                }
                .position(x: geometry.size.width * 0.5,
                          y: geometry.size.height * 0.65)
            }
        }
    }
}



struct CellContentsView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarCellView(
            date: Date(), schedules: [
                Schedule(title: "title",
                         description: "description",
                         priority: 1,
                         time: .period(start: Date().aMonthAgo,
                                       end: Date().aMonthAfter),
                         alarm: .once(Date())),
                Schedule(title: "title",
                         description: "description",
                         priority: 2,
                         time: .spot(Date()),
                         alarm: .once(Date())),
                Schedule(title: "title",
                         description: "description",
                         priority: 3,
                         time: .spot(Date()),
                         alarm: .once(Date()))
            ], searchRequest: nil,
            holiday: nil)
            .frame(
                width: 200,
                height: 300,
                alignment: .center)
            .border(Color.black)
    }
}

