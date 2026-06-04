import XCTest
import TPAUnitTestFoundation
@testable import TPAUIKit

@MainActor
private final class FakeProvider {
    weak var delegate: AnyViewModelProviderDelegate<String>?
    var pushOnConnect: String?

    var delegateDidSet: AnyViewModelProviderDelegate<String>? {
        didSet { if let pushOnConnect { delegate?.viewModelUpdated(pushOnConnect) } }
    }

    func push(_ value: String) { delegate?.viewModelUpdated(value) }
}

@MainActor
final class ViewModelStoreTests: AppTestCase {

    func test_store_publishesPushedViewModels() {
        let provider = FakeProvider()
        let store = ViewModelStore<String>(provider) { provider, delegate in
            provider.delegate = delegate
        }

        XCTAssertNil(store.viewModel)
        provider.push("hello")
        XCTAssertEqual(store.viewModel, "hello")
        provider.push("world")
        XCTAssertEqual(store.viewModel, "world")
    }

    func test_store_receivesImmediatePushWhenProviderPushesOnConnect() {
        let provider = FakeProvider()
        provider.pushOnConnect = "initial"
        let store = ViewModelStore<String>(provider) { provider, delegate in
            provider.delegate = delegate
            provider.delegateDidSet = delegate // simulate a provider that pushes on delegate-set
        }
        XCTAssertEqual(store.viewModel, "initial")
    }
}
