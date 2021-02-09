//
//  CellContentsView.swift
//  Simple Diary
//
//  Created by Shin on 2/8/21.
//

import SwiftUI

struct CellContentsView: View {
    var date: Int?
    var isToday = false
    var dateFontColor: Color {
        let date = Date.intToDate(self.date!)
        if date?.weekDay == 0 {
            return Color.pink
        }else if date?.weekDay == 6 {
            return Color.blue
        }else {
            return Color.black
        }
    }
    var body: some View {
        VStack{
            if date != nil {
                Text(String(date! % 100))
                    .font(.body)
                    .foregroundColor(dateFontColor)
                    .padding(10)
                    .overlay(isToday ? RoundedRectangle(cornerRadius: 100)
                                .stroke(Color.pink, lineWidth: 5)
                                : nil)
            }
        }
    }
}

struct CellContentsView_Previews: PreviewProvider {
    static var previews: some View {
        CellContentsView(date: 20210201)
            .frame(width: 100, height: 150)
    }
}
