import AppKit
import SwiftUI

struct ChooserView: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            if let errorMessage = appModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .lineLimit(3)
            }

            if appModel.isManagingBrowsers {
                manageBrowserList
            } else {
                chooserList
            }

            footer
        }
        .padding(20)
        .frame(minWidth: 560, minHeight: 432)
        .onMoveCommand(perform: handleMoveCommand)
        .onExitCommand(perform: appModel.cancelActiveRequest)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(hostText)
                .font(.title3)
                .bold()
                .lineLimit(1)

            Text(appModel.activeRequest?.url.absoluteString ?? "")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .textSelection(.enabled)
        }
    }

    private var chooserList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                if appModel.visibleBrowsers.isEmpty {
                    ContentUnavailableView(
                        "No Browsers",
                        systemImage: "globe",
                        description: Text("Open Manage, refresh the browser list, or unhide a browser.")
                    )
                    .frame(maxWidth: .infinity, minHeight: 280)
                } else {
                    ForEach(Array(appModel.visibleBrowsers.enumerated()), id: \.element.id) { index, browser in
                        browserButton(index: index, browser: browser)
                    }
                }
            }
            .padding(1)
        }
        .frame(maxHeight: .infinity)
    }

    private var manageBrowserList: some View {
        VStack(alignment: .leading, spacing: 10) {
            List {
                ForEach(appModel.orderedBrowsers) { browser in
                    HStack(spacing: 10) {
                        Image(nsImage: NSWorkspace.shared.icon(forFile: browser.appURL.path))
                            .resizable()
                            .frame(width: 24, height: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(browser.displayName)
                                .lineLimit(1)
                            Text(browser.bundleIdentifier ?? browser.appURL.path)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        Toggle("Visible", isOn: Binding(
                            get: { !appModel.isHidden(browser) },
                            set: { appModel.setHidden(browser, hidden: !$0) }
                        ))
                        .labelsHidden()

                        HStack(spacing: 4) {
                            Button {
                                appModel.moveBrowserUp(browser)
                            } label: {
                                Image(systemName: "chevron.up")
                            }
                            .buttonStyle(.borderless)
                            .help("Move up")

                            Button {
                                appModel.moveBrowserDown(browser)
                            } label: {
                                Image(systemName: "chevron.down")
                            }
                            .buttonStyle(.borderless)
                            .help("Move down")
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onMove(perform: appModel.moveBrowsers)
            }
            .frame(minHeight: 320, maxHeight: .infinity)

            HStack {
                Button("Refresh Browsers") {
                    appModel.refreshBrowsers()
                }

                Spacer()
            }
        }
    }

    @ViewBuilder
    private func browserButton(index: Int, browser: BrowserApp) -> some View {
        let row = BrowserRow(
            browser: browser,
            shortcut: index < 9 ? "\(index + 1)" : nil,
            isSelected: appModel.selectedBrowserID == browser.id
        )

        if index < 9 {
            Button {
                appModel.choose(browser)
            } label: {
                row
            }
            .buttonStyle(.plain)
            .keyboardShortcut(KeyEquivalent(Character("\(index + 1)")), modifiers: [])
        } else {
            Button {
                appModel.choose(browser)
            } label: {
                row
            }
            .buttonStyle(.plain)
        }
    }

    private var footer: some View {
        HStack {
            Button(appModel.isManagingBrowsers ? "Done" : "Manage") {
                appModel.isManagingBrowsers.toggle()
            }

            Spacer()

            Button("Cancel", role: .cancel) {
                appModel.cancelActiveRequest()
            }
            .keyboardShortcut(.escape, modifiers: [])

            if !appModel.isManagingBrowsers {
                Button("Open") {
                    appModel.chooseSelectedBrowser()
                }
                .keyboardShortcut(.return, modifiers: [])
                .disabled(appModel.selectedBrowserID == nil)
            }
        }
    }

    private var hostText: String {
        guard let url = appModel.activeRequest?.url else {
            return "Choose Browser"
        }

        return url.host(percentEncoded: false) ?? url.absoluteString
    }

    private func handleMoveCommand(_ direction: MoveCommandDirection) {
        guard !appModel.isManagingBrowsers else {
            return
        }

        switch direction {
        case .down:
            appModel.selectNextBrowser()
        case .up:
            appModel.selectPreviousBrowser()
        default:
            break
        }
    }
}

private struct BrowserRow: View {
    let browser: BrowserApp
    let shortcut: String?
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            if let shortcut {
                Text(shortcut)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 18)
            } else {
                Spacer()
                    .frame(width: 18)
            }

            Image(nsImage: NSWorkspace.shared.icon(forFile: browser.appURL.path))
                .resizable()
                .frame(width: 30, height: 30)

            Text(browser.displayName)
                .font(.body)
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear, in: .rect(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.accentColor.opacity(0.45) : Color.secondary.opacity(0.12))
        }
    }
}
