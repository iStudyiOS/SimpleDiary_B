
import SwiftUI


class CalendarCellVC: UICollectionViewCell {
    // Swift UI
    var hostingController = UIHostingController(rootView: CellContentsView())
    static func size(in frameSize: CGSize) -> CGSize{
        CGSize(width: ((frameSize.width - 2) / 8),
               height: ((frameSize.height - 2) / 7))
    }
}
