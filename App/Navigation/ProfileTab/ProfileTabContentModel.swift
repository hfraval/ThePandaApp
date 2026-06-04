import TPACore

enum ProfileTabContentModel: Equatable {
    case signedOut
    case signedIn(User)

    var isSignedIn: Bool {
        if case .signedIn = self { return true }
        return false
    }
}
