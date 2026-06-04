import XCTest
import TPAUnitTestFoundation
@testable import TPAFoundation

@MainActor
final class LocalizedStringsServiceTests: TestCase {
    private func makeService() -> LocalizedStringsService {
        LocalizedStringsService(bundle: Bundle(for: Self.self))
    }

    func test_missingKey_returnsKeyItself() {
        let result = makeService().localized(key: "some.missing.key", arguments: [])
        XCTAssertEqual(result, "some.missing.key")
    }

    func test_substitutesAnimalToken() {
        let result = makeService().localized(key: "%ANIMAL% rocks", arguments: [])
        XCTAssertFalse(result.contains("%ANIMAL%"), "the %ANIMAL% token must be replaced")
        XCTAssertTrue(result.hasSuffix(" rocks"))
    }

    func test_appliesFormatArguments() {
        let result = makeService().localized(key: "value %d", arguments: [5])
        XCTAssertEqual(result, "value 5")
    }
}
