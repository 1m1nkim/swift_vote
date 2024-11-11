import SwiftUI
import Firebase

@main
struct MyApp: App {
    // AppDelegate를 SwiftUI에서 사용하기 위해 추가
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView().preferredColorScheme(.light)
        }
    }
}
