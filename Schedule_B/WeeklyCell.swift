//
//  WeeklyCell.swift
//  Schedule_B
//
//  Created by Shin on 2/26/21.
//

import SwiftUI
import Combine

class WeeklyCell: UICollectionViewCell {
    var weeklyCellView: WeeklyCellView {
        get {
            weeklyCellHC.rootView
        }
        set{
            weeklyCellHC.rootView = newValue
        }
    }
    var weeklyCellHC = UIHostingController(rootView: WeeklyCellView())
    
    static func size(in frameSize: CGSize) -> CGSize {
        CGSize(width:
                frameSize.width / 6,
               height: frameSize.height)
    }
}
