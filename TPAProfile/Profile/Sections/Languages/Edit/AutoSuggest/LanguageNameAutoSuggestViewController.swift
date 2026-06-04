import UIKit
import TPAUIKit
import TPAFoundation

final class LanguageNameAutoSuggestViewController: UIViewController {

    private let viewModelProvider: SuggestedLanguageNamesViewModelProviderProtocol
    private var anyViewModelProviderDelegate: AnyViewModelProviderDelegate<SuggestedLanguageNamesViewModel>?
    private let onSelect: (LanguageNameSuggestion) -> Void
    private let initialText: String?

    private let searchField = FormTextField(title: nil, placeholder: localize("profile.languages.edit.namePlaceholder")).with {
        $0.textField.autocapitalizationType = .words
        $0.textField.clearButtonMode = .whileEditing
        $0.textField.accessibilityIdentifier = "language-name-search-field"
    }

    private let tableView = UITableView(frame: .zero, style: .plain).with {
        $0.accessibilityIdentifier = "language-suggestions-table"
    }

    private let loadingLabel = Label(typography: .footnote, textColor: AppColors.secondaryText).with {
        $0.text = localize("profile.languages.edit.searching")
        $0.isHidden = true
    }

    private var suggestions: [LanguageNameSuggestion] = []

    init(
        initialText: String?,
        viewModelProvider: SuggestedLanguageNamesViewModelProviderProtocol = SuggestedLanguageNamesViewModelProvider(),
        onSelect: @escaping (LanguageNameSuggestion) -> Void
    ) {
        self.initialText = initialText
        self.viewModelProvider = viewModelProvider
        self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)
        anyViewModelProviderDelegate = .init(self)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        title = localize("profile.languages.edit.nameLabel")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))

        searchField.text = initialText
        searchField.textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        [searchField, loadingLabel, tableView].forEach { view.addSubview($0.withAutoLayout()) }
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 12),
            searchField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            loadingLabel.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 8),
            loadingLabel.leadingAnchor.constraint(equalTo: searchField.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: loadingLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])

        viewModelProvider.delegate = anyViewModelProviderDelegate
        searchField.textField.becomeFirstResponder()
    }

    @objc private func textChanged() {
        post(LanguageNameAutoSuggestEvents.ValueChanged(text: searchField.textField.text))
    }

    @objc private func cancelTapped() { dismiss(animated: true) }
}

extension LanguageNameAutoSuggestViewController: ViewModelProviderDelegate {
    func viewModelUpdated(_ viewModel: SuggestedLanguageNamesViewModel) {
        switch viewModel {
        case .loading:
            loadingLabel.isHidden = false
        case .suggestions(let suggestions):
            loadingLabel.isHidden = true
            self.suggestions = suggestions
            tableView.reloadData()
        }
    }
}

extension LanguageNameAutoSuggestViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { suggestions.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = suggestions[indexPath.row].text
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelect(suggestions[indexPath.row])
        dismiss(animated: true)
    }
}
