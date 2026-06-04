import UIKit

public final class Button: UIButton {

    public enum Variant { case solid, ghost, transparent }
    public enum Size { case standard, small }
    public enum Tone { case brandAccent, critical, neutral }

    private let variant: Variant
    private let tone: Tone

    public var action: (() -> Void)?

    public var text: String? {
        get { title(for: .normal) }
        set { setTitle(newValue, for: .normal) }
    }

    public init(text: String? = nil, variant: Variant, size: Size = .standard, tone: Tone = .brandAccent) {
        self.variant = variant
        self.tone = tone
        super.init(frame: .zero)

        setTitle(text, for: .normal)
        titleLabel?.font = (size == .standard ? AppTypography.headline : AppTypography.subheadline)
        layer.cornerRadius = (size == .standard ? 12 : 8)
        contentEdgeInsets = (size == .standard
            ? UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)
            : UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14))

        applyStyle()
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override var isEnabled: Bool {
        didSet { alpha = isEnabled ? 1.0 : 0.5 }
    }

    private var toneColor: UIColor {
        switch tone {
        case .brandAccent: return AppColors.primary
        case .critical: return AppColors.error
        case .neutral: return AppColors.text
        }
    }

    private func applyStyle() {
        switch variant {
        case .solid:
            backgroundColor = toneColor
            setTitleColor(.white, for: .normal)
        case .ghost:
            backgroundColor = .clear
            layer.borderWidth = 1
            layer.borderColor = toneColor.cgColor
            setTitleColor(toneColor, for: .normal)
        case .transparent:
            backgroundColor = .clear
            setTitleColor(toneColor, for: .normal)
        }
    }

    @objc private func handleTap() { action?() }
}
