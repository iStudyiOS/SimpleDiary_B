//
//  MultiSegmentView.swift
//  Schedule_B
//
//  Created by Shin on 2/28/21.
//

import SwiftUI

struct MultiSegmentView: View {
    
    // MARK: Data
    @State var selectedIndices = Set<Int>()
    @State var dateToAdd: Int = 1
    private var weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    
    // MARK:- View properties
    
    var currentSegmentType: segmentType = .weekly
    
    private let selectedColor = Color.blue
    private let unSelectedColor = Color(white: 0.95)
    private func colorOfDay(_ day: String) -> Color {
        switch day {
        case "일":
            return Color.pink
        case "토":
            return Color.blue
        default:
            return Color.black
        }
    }
    /// Index of  selected date type
    enum segmentType: Int {
        case weekly = 2
        case monthly = 3
    }
    
    var body: some View {
        switch currentSegmentType {
        case .weekly:
            HStack(spacing: 10) {
                ForEach(Array(weekdays.enumerated()), id: \.element) { index, weekday in
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(Color.black)
                            .frame(width: 43,
                                   height: 43)
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(selectedIndices.contains(index) ? selectedColor : unSelectedColor)
                            .frame(width: 40,
                                   height: 40)
                        Text(weekday)
                            .foregroundColor(selectedIndices.contains(index) ? .white : colorOfDay(weekday))
                            .font(.title3)
                            .bold()
                    }
                    .onTapGesture {
                        if selectedIndices.contains(index) {
                            selectedIndices.remove(index)
                        }else {
                            selectedIndices.insert(index)
                        }
                    }
                }
            }
            .onAppear {
                selectedIndices.removeAll()
            }
        case .monthly:
            GeometryReader{ geometry in
                HStack{
                    VStack {
                        Text("매 월 ")
                        ForEach(selectedIndices.sorted(by: <), id: \.self) {
                            Text("\($0) 일")
                        }
                    }
                    Picker(selection: $dateToAdd, label: Text("매달 ")) {
                        ForEach(1..<32){
                            Text("\($0) 일")
                        }
                    }
                    .frame(maxWidth: geometry.size.width * 0.3)
                    Button(action: {
                        selectedIndices.insert(dateToAdd + 1)
                    }, label: {
                        HStack{
                            Image(systemName: "plus.circle")
                            Text("반복 추가")
                        }
                    })
                }
                .position(x: geometry.size.width * 0.6,
                          y: geometry.size.height * 0.5)
            }
            .onAppear {
                selectedIndices.removeAll()
            }
        }
    }
}

struct MultiSegmentView_Previews: PreviewProvider {
    static var previews: some View {
        MultiSegmentView()
            .frame(width: 350, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}
