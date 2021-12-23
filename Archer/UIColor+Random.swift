import UIKit

extension UIColor {
    static func random() -> UIColor {
        let red = CGFloat(Array(0...255).randomElement()!) / 255
        let green = CGFloat(Array(0...255).randomElement()!) / 255
        let blue = CGFloat(Array(0...255).randomElement()!) / 255
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        return color
    }
}
