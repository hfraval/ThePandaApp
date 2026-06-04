import UIKit
import TPAUIKit

final class SearchResultCell: UITableViewCell {
    static let reuseID = "SearchResultCell"

    private let thumbnail = Image(nil, contentMode: .scaleAspectFill).with {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.backgroundColor = AppColors.secondaryBackground
        $0.accessibilityIdentifier = "search-result-thumbnail"
        $0.widthAnchor.constraint(equalToConstant: 64).isActive = true
        $0.heightAnchor.constraint(equalToConstant: 64).isActive = true
    }

    private let titleLabel = Label(typography: .headline, textColor: AppColors.text, numberOfLines: 2)
    private let subtitleLabel = Label(typography: .subheadline, textColor: AppColors.primary)
    private let detailLabel = Label(typography: .footnote, textColor: AppColors.secondaryText)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        let labels = VStack(spacing: 4, [titleLabel, subtitleLabel, detailLabel])
        let row = HStack(spacing: 12, alignment: .center, [thumbnail, labels])
        contentView.addSubviewFill(row, insets: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnail.image = nil
    }

    func configure(with item: SearchResultItem) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        detailLabel.text = item.detail
        thumbnail.setRemoteImage(item.imageURL, placeholder: UIImage(systemName: "photo"))
    }
}
