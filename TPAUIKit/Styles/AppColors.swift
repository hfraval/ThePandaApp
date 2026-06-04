import UIKit

public enum AppColors {
    public static var primary: UIColor { UIColor(named: "BrandPrimary") ?? UIColor.systemGreen }
    public static var background: UIColor { UIColor.systemBackground }
    public static var secondaryBackground: UIColor { UIColor.secondarySystemBackground }
    public static var text: UIColor { UIColor.label }
    public static var secondaryText: UIColor { UIColor.secondaryLabel }
    public static var separator: UIColor { UIColor.separator }
    public static var error: UIColor { UIColor.systemRed }
    public static var success: UIColor { UIColor.systemGreen }
    public static var border: UIColor { UIColor.systemGray4 }
}
