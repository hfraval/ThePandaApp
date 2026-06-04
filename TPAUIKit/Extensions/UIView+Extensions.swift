import UIKit

public extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }

    @discardableResult
    func withAutoLayout() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }

    func addSubviewFill(_ view: UIView, insets: UIEdgeInsets = .zero, safeArea: Bool = false) {
        addSubview(view)
        if safeArea {
            view.pinEdges(to: safeAreaLayoutGuide, insets: insets)
        } else {
            view.pinEdges(to: self, insets: insets)
        }
    }

    func pinEdges(to view: UIView, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom)
        ])
    }

    func pinEdges(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -insets.bottom)
        ])
    }
}
