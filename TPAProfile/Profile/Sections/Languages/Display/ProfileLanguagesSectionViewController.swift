import UIKit
import TPACore
import TPAUIKit
import TPAFoundation

final class ProfileLanguagesSectionViewController: ProfileSectionViewController<LanguagesViewModel> {

    private let contentStack: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 0
        return sv
    }()

    init() {
        super.init(sectionTitle: localize("profile.languages.title"))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func configureViews() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.configure(title: localize("profile.languages.title"), actionTitle: localize("common.add"))
        headerView.onAction = { [weak self] in self?.presentEdit(languageProficiency: nil) }

        view.addSubviews(headerView, contentStack)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24)
        ])
    }

    override func render(viewModel: LanguagesViewModel) {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if viewModel.languages.isEmpty {
            let empty = LanguagesEmptyView()
            empty.onAdd = { [weak self] in self?.presentEdit(languageProficiency: nil) }
            contentStack.addArrangedSubview(empty)
        } else {
            for language in viewModel.languages {
                let card = DisclosureRowView()
                card.accessibilityIdentifier = "language-card-\(language.name)"
                card.configure(title: language.name, value: language.level.displayName)
                card.onTap = { [weak self] in self?.presentEdit(languageProficiency: language) }
                contentStack.addArrangedSubview(card)
            }
        }
    }

    private func presentEdit(languageProficiency: LanguageProficiency?) {
        let editViewController = EditLanguageViewController(languageProficiency: languageProficiency)
        present(editViewController.wrapInModalNavigationController(closeDelegate: editViewController), animated: true)
    }
}
