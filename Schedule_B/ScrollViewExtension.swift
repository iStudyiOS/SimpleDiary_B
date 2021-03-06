//
//  ScrollViewExtension.swift
//  Schedule_B
//
//  Created by KEEN on 2021/02/23.
//

import UIKit

extension UIScrollView {
  func scrollToChild(_ view:UIView, animated: Bool = false) {
    if let origin = view.superview {
      let childStartPoint = origin.convert(view.frame.origin, to: self)
      self.setContentOffset(CGPoint(x: childStartPoint.x, y: 0),
                            animated: animated)
    }
  }
}
