//
//  AppDelegate.swift
//  TopSen
//

import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var panelController: MemoPanelController?
    private var statusItem: NSStatusItem?
    private var globalHotKeyController: GlobalHotKeyController?

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
        configureGlobalHotKey()
    }

    func applicationWillTerminate(_ notification: Notification) {
        globalHotKeyController = nil
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

    @objc private func toggleMemoVisibility() {
        panelController?.toggleVisibility()
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
        let toggleItem = menuItem(
            title: "メモ表示を切り替え",
            action: #selector(toggleMemoVisibility),
            keyEquivalent: "m"
        )
        toggleItem.keyEquivalentModifierMask = [.command, .shift]
        menu.addItem(toggleItem)
        menu.addItem(.separator())
        menu.addItem(menuItem(title: "メモを表示", action: #selector(showMemo)))
        menu.addItem(menuItem(title: "メモを非表示", action: #selector(hideMemo)))
        menu.addItem(.separator())
        menu.addItem(menuItem(title: "メモ内容を消去…", action: #selector(confirmAndClearMemo)))
        menu.addItem(.separator())
        menu.addItem(menuItem(title: "TopSenを終了", action: #selector(terminateApplication)))

        item.menu = menu
        statusItem = item
    }

    private func menuItem(
        title: String,
        action: Selector,
        keyEquivalent: String = ""
    ) -> NSMenuItem {
        let item = NSMenuItem(
            title: title,
            action: action,
            keyEquivalent: keyEquivalent
        )
        item.target = self
        return item
    }

    private func configureGlobalHotKey() {
        do {
            globalHotKeyController = try GlobalHotKeyController { [weak self] in
                self?.panelController?.toggleVisibility()
            }
        } catch {
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = "ショートカットを登録できませんでした"
            alert.informativeText = error.localizedDescription
            alert.addButton(withTitle: "OK")
            NSApplication.shared.activate(ignoringOtherApps: true)
            alert.runModal()
        }
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
