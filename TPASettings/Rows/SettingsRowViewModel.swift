import Foundation
import TPAUIKit

struct SettingsRowViewModel: Equatable {
    enum Style: Equatable {
        case navigational
        case destructive
    }
    let title: String
    let style: Style
}
