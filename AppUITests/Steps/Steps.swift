import Foundation

protocol Steps {}

extension Steps {
    var Given: Self { self }
    var When: Self { self }
    var Then: Self { self }
    var And: Self { self }
}
