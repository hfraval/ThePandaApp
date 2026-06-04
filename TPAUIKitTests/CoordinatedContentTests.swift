import XCTest
import TPAUnitTestFoundation
@testable import TPAUIKit

private enum TestModel: Equatable { case a, b }

private final class FakeCoordinatedChild: UIViewController, CoordinatedContent {
    typealias ContentModel = TestModel

    private let visibleFor: TestModel
    private let canAdd: Bool
    private(set) var updateCount = 0

    init(visibleFor: TestModel, canAdd: Bool = true) {
        self.visibleFor = visibleFor
        self.canAdd = canAdd
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    func shouldAdd() -> Bool { canAdd }
    func shouldShow(for model: TestModel) -> Bool { model == visibleFor }
    func update(for model: TestModel) -> CoordinatedContentUpdate? {
        { [weak self] in self?.updateCount += 1 }
    }
}

private final class PlainChild: UIViewController, Content {
    private let canAdd: Bool
    init(canAdd: Bool) { self.canAdd = canAdd; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError() }
    func shouldAdd() -> Bool { canAdd }
}

private final class RecordingDelegate: ContentModelProviderDelegate {
    private(set) var latest: TestModel?
    func contentModelUpdated(_ contentModel: TestModel) { latest = contentModel }
}

@MainActor
final class CoordinatedContentTests: TestCase {

    private func makeContainer(
        _ a: FakeCoordinatedChild,
        _ b: FakeCoordinatedChild
    ) -> CoordinatedStackContentViewController<TestModel> {
        let vc = CoordinatedStackContentViewController<TestModel>(
            content: [AnyCoordinatedContent(a), AnyCoordinatedContent(b)]
        )
        vc.loadViewIfNeeded()
        return vc
    }

    func test_updateContent_showsMatchingChild_hidesOthers() {
        let a = FakeCoordinatedChild(visibleFor: .a)
        let b = FakeCoordinatedChild(visibleFor: .b)
        let container = makeContainer(a, b)

        container.updateContent(with: .a)
        XCTAssertFalse(a.view.isHidden)
        XCTAssertTrue(b.view.isHidden)

        container.updateContent(with: .b)
        XCTAssertTrue(a.view.isHidden)
        XCTAssertFalse(b.view.isHidden)
    }

    func test_updateContent_invokesUpdateOnEveryChild() {
        let a = FakeCoordinatedChild(visibleFor: .a)
        let b = FakeCoordinatedChild(visibleFor: .b)
        let container = makeContainer(a, b)

        container.updateContent(with: .a)

        XCTAssertEqual(a.updateCount, 1)
        XCTAssertEqual(b.updateCount, 1)
    }

    func test_contentModelUpdated_drivesChildren() {
        let a = FakeCoordinatedChild(visibleFor: .a)
        let b = FakeCoordinatedChild(visibleFor: .b)
        let container = makeContainer(a, b)

        container.contentModelProviderDelegate.contentModelUpdated(.b)

        XCTAssertTrue(a.view.isHidden)
        XCTAssertFalse(b.view.isHidden)
    }

    func test_addContent_skipsChildrenThatOptOut() {
        let included = PlainChild(canAdd: true)
        let excluded = PlainChild(canAdd: false)
        let container = StackContentViewController(content: [included, excluded])

        container.loadViewIfNeeded()

        XCTAssertEqual(container.content.count, 1)
        XCTAssertTrue(container.content.first?.viewController === included)
    }

    func test_anyContentModelProviderDelegate_holdsDelegateWeakly() {
        var delegate: RecordingDelegate? = RecordingDelegate()
        let erased = AnyContentModelProviderDelegate(delegate!)

        delegate = nil
        erased.contentModelUpdated(.a)

        XCTAssertNil(delegate)
    }
}
