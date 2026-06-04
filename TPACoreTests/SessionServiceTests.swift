import XCTest
import TPAUnitTestFoundation
@testable import TPACore

@MainActor
final class SessionServiceTests: TestCase {
    private var storage: MockLocalStorageService!
    private var logger: MockLogger!

    override func setUp() async throws {
        try await super.setUp()
        storage = MockLocalStorageService()
        logger = MockLogger()
    }

    override func tearDown() async throws {
        storage = nil; logger = nil
        try await super.tearDown()
    }

    private func makeService() -> SessionService {
        SessionService(storage: storage, logger: logger)
    }

    private let user = User(id: "u-1", email: "a@b.com")

    func test_newSession_startsSignedOut() {
        XCTAssertNil(makeService().currentUser)
    }

    func test_setUser_exposesCurrentUser() {
        let service = makeService()
        service.setUser(user)
        XCTAssertEqual(service.currentUser?.id, user.id)
    }

    func test_persistsSessionAcrossInstances() {
        makeService().setUser(user)
        let restored = makeService()
        XCTAssertEqual(restored.currentUser?.id, user.id)
    }

    func test_setUserNil_clearsPersistedSession() {
        let service = makeService()
        service.setUser(user)
        service.setUser(nil)

        XCTAssertNil(service.currentUser)
        XCTAssertNil(makeService().currentUser, "a new instance must not restore a cleared session")
    }

    func test_clearSession_clearsPersistedSession() {
        let service = makeService()
        service.setUser(user)
        service.clearSession()

        XCTAssertNil(service.currentUser)
        XCTAssertNil(makeService().currentUser)
    }
}
