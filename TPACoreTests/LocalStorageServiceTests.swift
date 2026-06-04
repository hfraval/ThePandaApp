import XCTest
import TPAUnitTestFoundation
@testable import TPACore

private struct Box: Codable, Equatable {
    let id: Int
    let name: String
}

@MainActor
final class LocalStorageServiceTests: TestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!
    private var service: LocalStorageService!

    override func setUp() async throws {
        try await super.setUp()
        suiteName = "LocalStorageServiceTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        service = LocalStorageService(defaults: defaults, logger: MockLogger())
    }

    override func tearDown() async throws {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil; suiteName = nil; service = nil
        try await super.tearDown()
    }

    func test_saveThenLoad_roundTrips() {
        let box = Box(id: 1, name: "Panda")
        service.save(box, forKey: "k")
        XCTAssertEqual(service.load(Box.self, forKey: "k"), box)
    }

    func test_load_missingKey_returnsNil() {
        XCTAssertNil(service.load(Box.self, forKey: "absent"))
    }

    func test_remove_deletesValue() {
        service.save(Box(id: 2, name: "Koala"), forKey: "k")
        service.remove(forKey: "k")
        XCTAssertNil(service.load(Box.self, forKey: "k"))
    }

    func test_load_typeMismatch_returnsNil() {
        service.save(Box(id: 3, name: "Rooster"), forKey: "k")
        XCTAssertNil(service.load([Int].self, forKey: "k"))
    }
}
