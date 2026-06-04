import Foundation

public extension Date {
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}
