import UIKit
import TPAFoundation

public final class AvatarView: UIView {
    private let diameter: CGFloat

    public init(
        image: UIImage?,
        diameter: CGFloat = 88,
        padding: CGFloat = 17,
        backgroundColor: UIColor = .white
    ) {
        self.diameter = diameter
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        clipsToBounds = true
        layer.cornerRadius = diameter / 2

        let imageView = UIImageView(image: image).with {
            $0.contentMode = .scaleAspectFit
        }
        addSubviewFill(imageView, insets: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override var intrinsicContentSize: CGSize { CGSize(width: diameter, height: diameter) }
}
