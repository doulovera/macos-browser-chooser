import AppKit
import CoreServices

struct BrowserApp: Identifiable, Equatable, Hashable {
    let id: String
    let bundleIdentifier: String?
    let displayName: String
    let appURL: URL
}

struct BrowserDiscovery {
    func discoverBrowsers() -> [BrowserApp] {
        var discovered: [BrowserApp] = []

        for scheme in ["https", "http"] {
            guard
                let url = URL(string: "\(scheme)://example.com"),
                let appURLs = LSCopyApplicationURLsForURL(url as CFURL, .all)?.takeRetainedValue() as? [URL]
            else {
                continue
            }

            discovered.append(contentsOf: appURLs.compactMap(makeBrowserApp(from:)))
        }

        var seenIDs = Set<String>()
        return discovered
            .filter { browser in
                guard browser.bundleIdentifier != Bundle.main.bundleIdentifier else {
                    return false
                }

                return seenIDs.insert(browser.id).inserted
            }
            .sorted { $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending }
    }

    private func makeBrowserApp(from appURL: URL) -> BrowserApp? {
        guard let bundle = Bundle(url: appURL) else {
            return nil
        }

        let bundleIdentifier = bundle.bundleIdentifier
        let id = bundleIdentifier ?? appURL.standardizedFileURL.path
        let displayName =
            bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? appURL.deletingPathExtension().lastPathComponent

        return BrowserApp(
            id: id,
            bundleIdentifier: bundleIdentifier,
            displayName: displayName,
            appURL: appURL
        )
    }
}
