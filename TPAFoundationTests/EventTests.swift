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

    // MARK: events(of:) — AsyncStream bridge

    func test_eventsStream_yieldsPostedPayload() async {
        // The observer is registered synchronously when the stream is created, and the default
        // unbounded buffer retains the payload until it is iterated.
        let stream = events(of: SampleEvent.self)
        post(SampleEvent(value: 42))

        var iterator = stream.makeAsyncIterator()
        let received = await iterator.next()

        XCTAssertEqual(received, SampleEvent(value: 42))
    }

    func test_eventsStream_yieldsMultiplePayloadsInOrder() async {
        let stream = events(of: SampleEvent.self)
        post(SampleEvent(value: 1))
        post(SampleEvent(value: 2))

        var iterator = stream.makeAsyncIterator()
        let first = await iterator.next()
        let second = await iterator.next()

        XCTAssertEqual(first, SampleEvent(value: 1))
        XCTAssertEqual(second, SampleEvent(value: 2))
    }

    func test_eventsStream_consumerTaskReceivesPayload() async {
        let stream = events(of: SampleEvent.self)
        let consumer = Task { () -> SampleEvent? in
            for await event in stream { return event }
            return nil
        }

        post(SampleEvent(value: 7))

        let received = await consumer.value
        XCTAssertEqual(received, SampleEvent(value: 7))
    }
}
