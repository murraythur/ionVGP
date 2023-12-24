import UIKit
import SwifteriOS

enum AuthorizationMode {
    @available(iOS, deprecated: 11.0)
    case acaccount
    case browser
    case sso
    
    var isUsingSSO: Bool {
        return self == .sso
    }
}

let authorizationMode: AuthorizationMode = .browser

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        return true
    }

    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {        
        if authorizationMode.isUsingSSO {
            let callbackUrl = URL(string: "swifter-nLl1mNYc25avPPF4oIzMyQzft://")!
            Swifter.handleOpenURL(url, callbackURL: callbackUrl, isSSO: true)
        } else {
            let callbackUrl = URL(string: "swifter://")!
            Swifter.handleOpenURL(url, callbackURL: callbackUrl)
        }
        return true
    }

    @available(iOS 13.0, *)
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
