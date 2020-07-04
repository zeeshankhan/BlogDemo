import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Toast.shared.show(text: "Ea voluptatibus a illo doloremque reiciendis nemo et earum. Molestiae totam voluptatibus nobis et deleniti dolores. Animi quasi ut voluptatem autem magni. Et voluptas repudiandae unde. Non sapiente maxime voluptas et facere enim.")

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        self.window = window

        window.rootViewController = UINavigationController(rootViewController: DemoListViewController())

        return true
    }
}
