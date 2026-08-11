//
//  MemoPanelController.swift
//  TopSen
//

import AppKit
import SwiftUI

@MainActor
final class MemoPanelController: NSObject, NSWindowDelegate {
    private let memoStore: MemoStore
    private let windowStateStore: WindowStateStore
    private let panel: MemoPanel
    private var screenParametersObserver: NSObjectProtocol?
    private var shouldBeVisible = false

    var isMemoVisible: Bool {
        shouldBeVisible
    }

    init(memoStore: MemoStore, windowStateStore: WindowStateStore) {
        self.memoStore = memoStore
        self.windowStateStore = windowStateStore

        let visibleFrames = NSScreen.screens.map(\.visibleFrame)
        let restoredFrame = windowStateStore.restoredFrame(
            visibleFrames: visibleFrames,
            mainVisibleFrame: NSScreen.main?.visibleFrame
        )

        panel = MemoPanel(
            contentRect: restoredFrame,
            styleMask: [
                .titled,
                .closable,
                .resizable,
                .fullSizeContentView,
                .nonactivatingPanel
            ],
            backing: .buffered,
            defer: false
        )

        super.init()
        configurePanel()
        observeScreenChanges()
    }

    deinit {
        if let screenParametersObserver {
            NotificationCenter.default.removeObserver(screenParametersObserver)
        }
    }

    func show() {
        shouldBeVisible = true
        panel.orderFrontRegardless()
    }

    func hide() {
        shouldBeVisible = false
        saveWindowState()
        panel.orderOut(nil)
    }

    func toggleVisibility() {
        if isMemoVisible {
            hide()
        } else {
            show()
        }
    }

    func saveWindowState() {
        windowStateStore.save(frame: panel.frame)
    }

    func confirmAndClearMemo() {
        let wasVisible = shouldBeVisible
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "メモ内容を消去しますか？"
        alert.informativeText = "この操作は取り消せません。"
        alert.addButton(withTitle: "消去")
        alert.addButton(withTitle: "キャンセル")

        NSApplication.shared.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        alert.beginSheetModal(for: panel) { [weak self] response in
            guard let self else { return }
            if response == .alertFirstButtonReturn {
                self.memoStore.clear()
            }
            if !wasVisible {
                self.panel.orderOut(nil)
            }
        }
    }

    func windowDidMove(_ notification: Notification) {
        saveWindowState()
    }

    func windowDidResize(_ notification: Notification) {
        saveWindowState()
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        shouldBeVisible = false
        saveWindowState()
        sender.orderOut(nil)
        return false
    }

    private func configurePanel() {
        panel.title = "TopSen"
        panel.delegate = self
        panel.level = .screenSaver
        panel.hidesOnDeactivate = false
        panel.isFloatingPanel = true
        panel.becomesKeyOnlyIfNeeded = false
        panel.collectionBehavior = [
            .canJoinAllSpaces,
            .canJoinAllApplications,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]
        panel.isReleasedWhenClosed = false
        panel.minSize = WindowStateStore.minimumSize
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.titlebarSeparatorStyle = .none
        panel.animationBehavior = .utilityWindow

        let hostingView = NSHostingView(rootView: MemoView(store: memoStore))
        hostingView.wantsLayer = true
        hostingView.layer?.cornerRadius = 12
        hostingView.layer?.masksToBounds = true
        panel.contentView = hostingView
    }

    private func observeScreenChanges() {
        screenParametersObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.restoreFrameToCurrentScreens()
            }
        }
    }

    private func restoreFrameToCurrentScreens() {
        saveWindowState()
        let visibleFrames = NSScreen.screens.map(\.visibleFrame)
        let restoredFrame = windowStateStore.restoredFrame(
            visibleFrames: visibleFrames,
            mainVisibleFrame: NSScreen.main?.visibleFrame
        )
        panel.setFrame(restoredFrame, display: true, animate: false)
        saveWindowState()
    }
}
