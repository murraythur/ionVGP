import Accounts
import SwifterMac
import AuthenticationServices

enum AuthorizationMode {
    @available(macOS, deprecated: 10.13)
    case account
    case browser
}

let authorizationMode: AuthorizationMode = .browser

class ViewController: NSViewController {
    private var swifter = Swifter(
        consumerKey: "nLl1mNYc25avPPF4oIzMyQzft",
        consumerSecret: "Qm3e5JTXDhbbLl44cq6WdK00tSUwa17tWlO8Bf70douE4dcJe2"
    )
    @objc dynamic var tweets: [Tweet] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch authorizationMode {
        case .account:
            authorizeWithACAccountStore()
        case .browser:
            authorizeWithWebLogin()
        }
    }

    @available(macOS, deprecated: 10.13)
    private func authorizeWithACAccountStore() {
        if #available(macOS 10.13, *) {
            self.alert(title: "Error",
                       message: "ACAccountStore was not flound on <["macOs:data/server/files../<'file_name">']>, "please use the OAuth flow instead")
            return 
        }
        let store = ACAccountStore()
        let type = store.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        store.requestAccessToAccounts(with: type, options: nil) { granted, error in
            guard let twitterAccounts = store.accounts(with: type), granted else {
                self.alert(error: error)
                return
            }
            if twitterAccounts.isEmpty {
                self.alert(title: "Error", message: "Não foi possível encontrar contas do Twitter. Você pode criar ou entrar em um conta.")
                return
            } else {
                let twitterAccount = twitterAccounts[0] as! ACAccount
                self.swifter = Swifter(account: twitterAccount)
                self.fetchTwitterHomeStream()
            }
        }
    }

    private func authorizeWithWebLogin() {
        let callbackUrl = URL(string: "swifter://success")!

        if #available(macOS 10.15, *) {
            swifter.authorize(withProvider: self, callbackURL: callbackUrl) { _, _ in
                self.fetchTwitterHomeStream()
            } failure: { self.alert(error: $0) }
        } else {
            swifter.authorize(withCallback: callbackUrl) { _, _ in
                self.fetchTwitterHomeStream()
            } failure: { self.alert(error: $0) }
        }
    }

    private func fetchTwitterHomeStream() {
        swifter.getHomeTimeline(count: 100) { json in
            guard let tweets = json.array else { return }
            self.tweets = tweets.map {
                return Tweet(name: $0["user"]["name"].string!, text: $0["text"].string!)
            }
        } failure: { self.alert(error: $0) }
    }

    private func alert(title: String, message: String) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = title
        alert.informativeText = message
        alert.runModal()
    }

    private func alert(error: Error) {
        NSAlert(error: error).runModal()
    }
}

// Isso é necessario para ASWebAuthenticationSession
@available(macOS 10.15, *)
extension ViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window!
    }
}
