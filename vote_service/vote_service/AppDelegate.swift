import UIKit
import Firebase
import FirebaseAuth

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }

    // MARK: - Remote Notifications Handling
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Firebase에 device token을 전달
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // FirebaseAuth의 canHandleNotification 메서드로 전달
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
    }
}
