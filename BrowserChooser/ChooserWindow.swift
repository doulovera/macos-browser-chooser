import AppKit
import SwiftUI

@MainActor
final class ChooserWindow {
    private let window: NSWindow

    init(appModel: AppModel) {
        let contentView = ChooserView(appModel: appModel)
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 620, height: 512),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        window.title = "Choose Browser"
        window.minSize = NSSize(width: 560, height: 440)
        window.maxSize = NSSize(width: 760, height: 700)
        window.isReleasedWhenClosed = false
        window.center()
        window.contentView = NSHostingView(rootView: contentView)
    }

    func show() {
        window.center()
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    func close() {
        window.close()
    }
}
