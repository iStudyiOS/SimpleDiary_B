

import UIKit

extension UIScrollView {
    // Scroll to a specific view so that it's top is at the top our scrollview
    func scrollToChild(_ view:UIView, animated: Bool = false) {
        if let origin = view.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
            self.setContentOffset(CGPoint(x: childStartPoint.x, y: 0),
                                  animated: animated)
        }
    }
}
