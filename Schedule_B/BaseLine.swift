//
//  DailyTableBaseLine.swift
//  Schedule_B
//
//  Created by Shin on 2/27/21.
//

import SwiftUI

struct DailyTableBaseLine: View {
    
    // MARK: View properties
    private let lineWidth: CGFloat
    private let lineHeight: CGFloat
    private let lineRange = Range(1...24)
    
    private func getTimeLabel(of ordinalNumber: Int) -> String{
        var hour: String
        if  ordinalNumber % 12 == 0 {
            hour = "12"
        }else if ordinalNumber % 12 < 10 {
            hour = "  \(ordinalNumber % 12)"
        }else {
            hour = "\(ordinalNumber % 12)"
        }
        let sign = ordinalNumber < 12 ? "  AM" : "  PM"
        return hour + sign
    }
    var body: some View {
        VStack{
            ForEach(lineRange) { ordinalNumber in
                HStack {
                    Text(getTimeLabel(of: ordinalNumber))
                        .foregroundColor(Color(white: 0.4))
                        .offset(x: 30)
                    Path{ path in
                        path.move(to: CGPoint(x: 50, y: lineHeight / 2 ))
                        path.addLine(to: CGPoint(x: lineWidth,
                                                 y: lineHeight / 2))
                    }
                    .stroke(Color(.opaqueSeparator), lineWidth: 2)
                }
                .frame(width: lineWidth, height: lineHeight)
            }
        }
    }
    init(width: CGFloat = 450, lineHeight: CGFloat = 50) {
        lineWidth = width
        self.lineHeight = lineHeight
    }
}

struct DailyTableBaseLine_Previews: PreviewProvider {
    static var previews: some View {
        DailyTableBaseLine()
    }
}
