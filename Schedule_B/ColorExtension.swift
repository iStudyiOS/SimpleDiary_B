
import SwiftUI

extension CGColor {
    static var salmon: CGColor {
        CGColor(red: 0.98, green: 0.52, blue: 0.55, alpha: 0.8)
    }
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1)
    }
    convenience init(rgb: Int) {
           self.init(
               red: (rgb >> 16) & 0xFF,
               green: (rgb >> 8) & 0xFF,
               blue: rgb & 0xFF
           )
       }
    static func byPriority(_ priority: Int) -> UIColor {
        return UIColor(Color.byPriority(priority))
    }
}
extension Color {
    static func forDate(_ date: Date) -> Color {
        if date.weekDay == 1 {
            return Color.pink
        }else if date.weekDay == 7 {
            return Color.blue
        }else {
            return Color(.darkGray)
        }
    }
    enum Button: String, CaseIterable {
        case red = "🔴"
        case orange = "🟠"
        case green = "🟢"
        case blue = "🔵"
        case black = "⚫️"
    }
    static func byPriority(_ priority: Int) -> Color {
        guard priority > 0 , priority < 6 else {
            fatalError("Drawing fail: Invalid priority of schedule is passed to cell")
        }
        switch priority {
        case 1:
            return Color.red
        case 2:
            return Color.orange
        case 3:
            return Color.green
        case 4:
            return Color.blue
        default:
            return Color.black
        }
    }
}
