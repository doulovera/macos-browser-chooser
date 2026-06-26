import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let appModel = AppModel()
    private var chooserWindow: ChooserWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        appModel.onNeedsPresentation = { [weak self] in
            self?.showChooserIfNeeded()
        }

        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleGetURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )

        appModel.refreshBrowsers()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    @objc
    private func handleGetURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        guard
            let rawURL = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
            let url = URL(string: rawURL)
        else {
            return
        }

        appModel.enqueue(url)
    }

    private func showChooserIfNeeded() {
        guard appModel.activeRequest != nil else {
            chooserWindow?.close()
            chooserWindow = nil
            return
        }

        if chooserWindow == nil {
            chooserWindow = ChooserWindow(appModel: appModel)
        }

        chooserWindow?.show()
    }
}
