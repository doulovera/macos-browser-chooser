import Foundation

struct PreferencesStore {
    var hiddenBrowserIDs: Set<String> {
        get {
            Set(defaults.stringArray(forKey: Keys.hiddenBrowserIDs) ?? [])
        }
        set {
            defaults.set(Array(newValue).sorted(), forKey: Keys.hiddenBrowserIDs)
        }
    }

    var browserOrder: [String] {
        get {
            defaults.stringArray(forKey: Keys.browserOrder) ?? []
        }
        set {
            defaults.set(newValue, forKey: Keys.browserOrder)
        }
    }

    private let defaults = UserDefaults.standard

    func save() {
        defaults.synchronize()
    }

    private enum Keys {
        static let hiddenBrowserIDs = "hiddenBrowserIDs"
        static let browserOrder = "browserOrder"
    }
}
