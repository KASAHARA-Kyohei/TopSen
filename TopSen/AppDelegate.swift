//
//  AppDelegate.swift
//  TopSen
//

import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var panelController: MemoPanelController?
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)

        let defaults = persistenceDefaults()
        let memoStore = MemoStore(defaults: defaults)
        let windowStateStore = WindowStateStore(defaults: defaults)
        let controller = MemoPanelController(
            memoStore: memoStore,
            windowStateStore: windowStateStore
        )

        panelController = controller
        configureStatusItem()
        controller.show()
    }

    func applicationWillTerminate(_ notification: Notification) {
        panelController?.saveWindowState()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    @objc private func showMemo() {
        panelController?.show()
    }

    @objc private func hideMemo() {
        panelController?.hide()
    }

    @objc private func confirmAndClearMemo() {
        panelController?.confirmAndClearMemo()
    }

    @objc private func terminateApplication() {
        NSApplication.shared.terminate(nil)
    }

    private func configureStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            button.image = NSImage(
                systemSymbolName: "note.text",
                accessibilityDescription: "TopSen"
            )
            button.image?.isTemplate = true
            button.toolTip = "TopSen"
            button.setAccessibilityLabel("TopSen")
        }

        let menu = NSMenu()
        menu.addItem(menuItem(title: "メモを表示", action: #selector(showMemo)))
        menu.addItem(menuItem(title: "メモを非表示", action: #selector(hideMemo)))
        menu.addItem(.separator())
        menu.addItem(menuItem(title: "メモ内容を消去…", action: #selector(confirmAndClearMemo)))
        menu.addItem(.separator())
        menu.addItem(menuItem(title: "TopSenを終了", action: #selector(terminateApplication)))

        item.menu = menu
        statusItem = item
    }

    private func menuItem(title: String, action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        return item
    }

    private func persistenceDefaults() -> UserDefaults {
        let environment = ProcessInfo.processInfo.environment
        guard let suiteName = environment["TOPSEN_USER_DEFAULTS_SUITE"],
              !suiteName.isEmpty,
              let defaults = UserDefaults(suiteName: suiteName) else {
            return .standard
        }
        return defaults
    }
}
