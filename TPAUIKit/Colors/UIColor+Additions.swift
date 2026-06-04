import UIKit

public extension UIColor {

    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: 1.0
        )
    }

    convenience init(netHex: Int) {
        self.init(
            red: (netHex >> 16) & 0xff,
            green: (netHex >> 8) & 0xff,
            blue: netHex & 0xff
        )
    }

    convenience init?(hexString: String) {
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#") {
            scanner.currentIndex = hexString.index(after: hexString.startIndex)
        }
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        self.init(netHex: Int(color))
    }

    func toHexString() -> String {
        let r: CGFloat = cgColor.components?[0] ?? 0
        let g: CGFloat = cgColor.components?[1] ?? 0
        let b: CGFloat = cgColor.components?[2] ?? 0
        return String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
    }

    static func dynamic(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? dark : light
        }
    }
}

public extension UIColor {
    static func brandPrimary() -> UIColor {
        UIColor(named: "BrandPrimary") ?? UIColor.systemGreen
    }

    static func surfaceSecondary() -> UIColor {
        UIColor(named: "SurfaceSecondary") ?? UIColor.systemGray6
    }
}
