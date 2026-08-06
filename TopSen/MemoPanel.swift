//
//  MemoPanel.swift
//  TopSen
//

import AppKit

final class MemoPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    override func sendEvent(_ event: NSEvent) {
        if event.type == .leftMouseDown {
            NSApplication.shared.activate(ignoringOtherApps: true)
            makeKey()
        }
        super.sendEvent(event)
    }
}
