//
//  CalenderCellVC.swift
//  Schedule_B
//
//  Created by KEEN on 2021/02/23.
//

import SwiftUI
import Combine

class CalendarCellVC: UICollectionViewCell {
  var cellView: CellContentsView {
    get {
      hostingController.rootView
    }
    set{
      hostingController.rootView = newValue
    }
  }
  
  
  // Swift UI
  var hostingController = UIHostingController(rootView: CellContentsView())
  static func size(in frameSize: CGSize) -> CGSize{
    CGSize(width: ((frameSize.width - 2) / 8),
           height: ((frameSize.height - 2) / 7))
  }
}
