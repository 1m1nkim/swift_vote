import Foundation

class LocalUserDefaults {
    static let shared = LocalUserDefaults()

    private init() {}

    func set(key: UserDefaultsKey, value: Any?) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

    func value(key: UserDefaultsKey) -> Any? {
        return UserDefaults.standard.value(forKey: key.rawValue)
    }
}

enum UserDefaultsKey: String {
    case verificationID
    case FirebaseidToken
}
