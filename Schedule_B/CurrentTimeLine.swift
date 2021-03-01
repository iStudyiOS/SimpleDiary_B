//
//  DailyTableCurrentTimeLine.swift
//  Schedule_B
//
//  Created by Shin on 2/28/21.
//

import SwiftUI

struct DailyTableCurrentTimeLine: View {
    private let scrollHeight: CGFloat
    private let size: CGSize
    
    var body: some View {
        Path { path in
            let now = Date()
            let yPosition = scrollHeight * CGFloat((now - now.startOfDay) / TimeInterval.forOneDay) * 1.2
            path.move(to: CGPoint(
                        x: 0,
                        y: yPosition))
            path.addLine(to: CGPoint(
                            x: size.width,
                            y: yPosition))
        }
        .stroke(Color.red, lineWidth: 2.5)

    }
    init(scrollHeight: CGFloat, in size: CGSize) {
        self.scrollHeight = scrollHeight
        self.size = size
    }
}
