import XCTest
import UIKit

nonisolated(unsafe) public var isRecordingSnapshots = false

public struct SnapshotConfig: Sendable {
    public var userInterfaceStyle: UIUserInterfaceStyle
    public var size: CGSize

    public init(userInterfaceStyle: UIUserInterfaceStyle = .light,
                size: CGSize = CGSize(width: 393, height: 852)) {
        self.userInterfaceStyle = userInterfaceStyle
        self.size = size
    }
}

public let defaultSnapshotConfigs: [String: SnapshotConfig] = [
    "light": SnapshotConfig(userInterfaceStyle: .light),
    "dark": SnapshotConfig(userInterfaceStyle: .dark)
]

@MainActor
public func assertAppearance(
    configs: [String: SnapshotConfig] = defaultSnapshotConfigs,
    record: Bool = false,
    settleTime: TimeInterval = 0.2,
    afterLayout: ((UIViewController) -> Void)? = nil,
    file: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    _ createViewController: () -> UIViewController
) {
    let directory = referenceDirectory(for: file)
    let base = testName.replacingOccurrences(of: "()", with: "")

    for name in configs.keys.sorted() {
        guard let config = configs[name] else { continue }
        let image = render(createViewController(), config: config, settleTime: settleTime, afterLayout: afterLayout)
        let referenceURL = directory.appendingPathComponent("\(base).\(name).png")

        let shouldRecord = record || isRecordingSnapshots
            || !FileManager.default.fileExists(atPath: referenceURL.path)

        if shouldRecord {
            writePNG(image, to: referenceURL)
            attach(image, named: "\(base).\(name) (recorded)")
            XCTFail("Recorded snapshot '\(base).\(name)'. Re-run to verify against it.", file: file, line: line)
            continue
        }

        guard let reference = UIImage(contentsOfFile: referenceURL.path) else {
            XCTFail("Could not load reference snapshot '\(base).\(name)'.", file: file, line: line)
            continue
        }

        if !imagesMatch(image, reference) {
            attach(reference, named: "\(base).\(name) (reference)")
            attach(image, named: "\(base).\(name) (actual)")
            XCTFail("Snapshot '\(base).\(name)' does not match its reference.", file: file, line: line)
        }
    }
}

@MainActor
private func render(
    _ viewController: UIViewController,
    config: SnapshotConfig,
    settleTime: TimeInterval,
    afterLayout: ((UIViewController) -> Void)?
) -> UIImage {
    let window = UIWindow(frame: CGRect(origin: .zero, size: config.size))
    window.overrideUserInterfaceStyle = config.userInterfaceStyle
    window.rootViewController = viewController
    window.makeKeyAndVisible()
    viewController.view.frame = window.bounds
    window.layoutIfNeeded()

    if settleTime > 0 {
        RunLoop.current.run(until: Date().addingTimeInterval(settleTime))
    }
    window.layoutIfNeeded()

    if let afterLayout {
        afterLayout(viewController)
        window.layoutIfNeeded()
    }

    let format = UIGraphicsImageRendererFormat()
    format.scale = 2
    let renderer = UIGraphicsImageRenderer(bounds: window.bounds, format: format)
    return renderer.image { context in
        window.layer.render(in: context.cgContext)
    }
}

private func imagesMatch(_ lhs: UIImage, _ rhs: UIImage, perChannelTolerance: Int = 16, allowedRatio: Double = 0.02) -> Bool {
    guard let a = rgbaBytes(lhs), let b = rgbaBytes(rhs),
          a.width == b.width, a.height == b.height, a.bytes.count == b.bytes.count else {
        return false
    }
    var differing = 0
    for i in 0..<a.bytes.count where abs(Int(a.bytes[i]) - Int(b.bytes[i])) > perChannelTolerance {
        differing += 1
    }
    return Double(differing) / Double(a.bytes.count) <= allowedRatio
}

private func rgbaBytes(_ image: UIImage) -> (bytes: [UInt8], width: Int, height: Int)? {
    guard let cg = image.cgImage else { return nil }
    let width = cg.width, height = cg.height
    var bytes = [UInt8](repeating: 0, count: width * height * 4)
    guard let context = CGContext(
        data: &bytes, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
        space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }
    context.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))
    return (bytes, width, height)
}

private func referenceDirectory(for file: StaticString) -> URL {
    let path = "\(file)"
    let fileURL = URL(fileURLWithPath: path)
    let testFileName = fileURL.deletingPathExtension().lastPathComponent
    let directory = fileURL.deletingLastPathComponent()
        .appendingPathComponent("__Snapshots__")
        .appendingPathComponent(testFileName)
    try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory
}

private func writePNG(_ image: UIImage, to url: URL) {
    guard let data = image.pngData() else { return }
    try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try? data.write(to: url)
}

@MainActor
private func attach(_ image: UIImage, named name: String) {
    XCTContext.runActivity(named: name) { activity in
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        activity.add(attachment)
    }
}
