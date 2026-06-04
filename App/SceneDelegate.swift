import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private let rootController = RootController()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        if isRunningUnitTests { return }

        let w = rootController.makeWindow(for: windowScene)
        self.window = w
        rootController.presentMainApp()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        guard !isRunningUnitTests else { return }
        rootController.handleWarmStart()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}

    private var isRunningUnitTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}
