import XCTest

public extension XCTestCase {
    func waitForMainQueue() {
        let expectation = expectation(description: "main queue")
        DispatchQueue.main.async { expectation.fulfill() }
        wait(for: [expectation], timeout: 1.0)
    }

    func awaitAsync(timeout: TimeInterval = 2.0, operation: @escaping @Sendable () async -> Void) {
        let expectation = expectation(description: "async operation")
        Task {
            await operation()
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
    }
}
