import Foundation
import TPAFoundation

@MainActor
protocol RunSearchActionProtocol {
    func callAsFunction(query: SearchQuery)
}

@MainActor
final class RunSearchAction: RunSearchActionProtocol {
    @Resolved private var service: SearchRunServiceProtocol

    init() {}

    func callAsFunction(query: SearchQuery) {
        Task { await service.run(query) }
    }
}
