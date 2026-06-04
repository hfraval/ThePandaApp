import Foundation

public extension Collection {
    var isNotEmpty: Bool {
        !isEmpty
    }

    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
