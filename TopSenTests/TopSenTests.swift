//
//  TopSenTests.swift
//  TopSenTests
//

import AppKit
import Testing
@testable import TopSen

@MainActor
struct TopSenTests {
    @Test
    func memoIsSavedRestoredAndCleared() {
        let (defaults, domain) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: domain) }

        let store = MemoStore(defaults: defaults, key: "memo")
        #expect(store.text.isEmpty)

        store.text = "1行目\n日本語のメモ"
        let restoredStore = MemoStore(defaults: defaults, key: "memo")
        #expect(restoredStore.text == "1行目\n日本語のメモ")

        restoredStore.clear()
        #expect(defaults.string(forKey: "memo") == "")
    }

    @Test
    func windowFrameIsSavedAndRestoredInsideVisibleScreen() {
        let (defaults, domain) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: domain) }

        let store = WindowStateStore(defaults: defaults, key: "frame")
        let screen = NSRect(x: 0, y: 0, width: 1_000, height: 700)
        store.save(frame: NSRect(x: 700, y: 500, width: 360, height: 240))

        let restored = store.restoredFrame(
            visibleFrames: [screen],
            mainVisibleFrame: screen
        )

        #expect(restored == NSRect(x: 640, y: 460, width: 360, height: 240))
    }

    @Test
    func offscreenFrameFallsBackToMainScreen() {
        let (defaults, domain) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: domain) }

        let store = WindowStateStore(defaults: defaults, key: "frame")
        let screen = NSRect(x: 0, y: 0, width: 1_000, height: 700)
        store.save(frame: NSRect(x: 2_000, y: 2_000, width: 500, height: 400))

        let restored = store.restoredFrame(
            visibleFrames: [screen],
            mainVisibleFrame: screen
        )

        #expect(restored == NSRect(x: 616, y: 436, width: 360, height: 240))
    }

    @Test
    func undersizedFrameUsesMinimumSize() {
        let (defaults, domain) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: domain) }

        let store = WindowStateStore(defaults: defaults, key: "frame")
        let screen = NSRect(x: 0, y: 0, width: 1_000, height: 700)
        store.save(frame: NSRect(x: 100, y: 100, width: 80, height: 60))

        let restored = store.restoredFrame(
            visibleFrames: [screen],
            mainVisibleFrame: screen
        )

        #expect(restored == NSRect(x: 100, y: 100, width: 240, height: 160))
    }

    private func makeDefaults() -> (UserDefaults, String) {
        let domain = "TopSenTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: domain)!
        defaults.removePersistentDomain(forName: domain)
        return (defaults, domain)
    }
}
