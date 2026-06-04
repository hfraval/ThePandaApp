import XCTest
import TPAUnitTestFoundation
@testable import TPAFoundation

private struct SampleEvent: Event, Equatable {
    let value: Int
}

private final class Spy: NSObject {
    private(set) var received: SampleEvent?
    @objc func onEvent(_ note: Notification) {
        received = note.eventPayload()
    }
}

@MainActor
final class EventTests: TestCase {
    private var spy: Spy!

    override func setUp() async throws {
        try await super.setUp()
        ServiceContainer.shared.registerInstance(NotificationCenter(), as: NotificationCenter.self)
        spy = Spy()
    }

    override func tearDown() async throws {
        spy = nil
        try await super.tearDown()
    }

    func test_post_deliversTypedPayloadToObserver() {
        TPAFoundation.observe(spy, event: SampleEvent.self, selector: #selector(Spy.onEvent(_:)))
        post(SampleEvent(value: 42))
        XCTAssertEqual(spy.received, SampleEvent(value: 42))
    }

    func test_eventPost_instanceMethod_delivers() {
        TPAFoundation.observe(spy, event: SampleEvent.self, selector: #selector(Spy.onEvent(_:)))
        SampleEvent(value: 7).post()
        XCTAssertEqual(spy.received, SampleEvent(value: 7))
    }

    func test_observer_notRegistered_receivesNothing() {
        post(SampleEvent(value: 1))
        XCTAssertNil(spy.received)
    }

    func test_notificationName_isStableAndTypeDerived() {
        XCTAssertEqual(SampleEvent.notificationName, SampleEvent.notificationName)
        XCTAssertTrue(SampleEvent.notificationName.rawValue.contains("SampleEvent"))
    }
}
