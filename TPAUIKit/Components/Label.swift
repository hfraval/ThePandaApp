import UIKit

public enum Typography {
    case largeTitle, title1, title2, title3, heading2, headline, body, body2, subheadline, footnote, caption

    public var font: UIFont {
        switch self {
        case .largeTitle: return AppTypography.largeTitle
        case .title1: return AppTypography.title1
        case .title2: return AppTypography.title2
        case .title3: return AppTypography.title3
        case .heading2: return AppTypography.title2
        case .headline: return AppTypography.headline
        case .body: return AppTypography.body
        case .body2: return AppTypography.subheadline
        case .subheadline: return AppTypography.subheadline
        case .footnote: return AppTypography.footnote
        case .caption: return AppTypography.caption1
        }
    }
}

public final class Label: UILabel {
    public init(
        typography: Typography,
        textColor: UIColor = AppColors.text,
        textAlignment: NSTextAlignment = .natural,
        numberOfLines: Int = 1
    ) {
        super.init(frame: .zero)
        self.font = typography.font
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.numberOfLines = numberOfLines
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
