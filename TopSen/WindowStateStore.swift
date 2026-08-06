//
//  WindowStateStore.swift
//  TopSen
//

import AppKit
import Foundation

struct WindowStateStore {
    static let defaultKey = "memo.windowFrame"
    static let defaultSize = NSSize(width: 360, height: 240)
    static let minimumSize = NSSize(width: 240, height: 160)

    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = WindowStateStore.defaultKey) {
        self.defaults = defaults
        self.key = key
    }

    func save(frame: NSRect) {
        defaults.set(NSStringFromRect(frame), forKey: key)
    }

    func savedFrame() -> NSRect? {
        guard let value = defaults.string(forKey: key) else {
            return nil
        }

        let frame = NSRectFromString(value)
        guard frame.width.isFinite,
              frame.height.isFinite,
              frame.origin.x.isFinite,
              frame.origin.y.isFinite,
              frame.width > 0,
              frame.height > 0 else {
            return nil
        }

        return frame
    }

    func restoredFrame(
        visibleFrames: [NSRect],
        mainVisibleFrame: NSRect?
    ) -> NSRect {
        let fallbackScreen = mainVisibleFrame ?? visibleFrames.first ?? NSRect(
            x: 0,
            y: 0,
            width: 1_440,
            height: 900
        )

        guard let savedFrame = savedFrame() else {
            return defaultFrame(in: fallbackScreen)
        }

        let intersections = visibleFrames.map { screen in
            (screen: screen, area: intersectionArea(of: savedFrame, and: screen))
        }
        let bestIntersection = intersections.max { $0.area < $1.area }

        guard let bestIntersection, bestIntersection.area > 0 else {
            return defaultFrame(in: fallbackScreen)
        }

        return clamped(frame: savedFrame, to: bestIntersection.screen)
    }

    private func defaultFrame(in screen: NSRect) -> NSRect {
        let width = min(Self.defaultSize.width, screen.width)
        let height = min(Self.defaultSize.height, screen.height)
        let margin: CGFloat = 24
        let x = max(screen.minX, screen.maxX - width - margin)
        let y = max(screen.minY, screen.maxY - height - margin)

        return NSRect(x: x, y: y, width: width, height: height)
    }

    private func clamped(frame: NSRect, to screen: NSRect) -> NSRect {
        let minimumWidth = min(Self.minimumSize.width, screen.width)
        let minimumHeight = min(Self.minimumSize.height, screen.height)
        let width = min(max(frame.width, minimumWidth), screen.width)
        let height = min(max(frame.height, minimumHeight), screen.height)
        let x = min(max(frame.minX, screen.minX), screen.maxX - width)
        let y = min(max(frame.minY, screen.minY), screen.maxY - height)

        return NSRect(x: x, y: y, width: width, height: height)
    }

    private func intersectionArea(of lhs: NSRect, and rhs: NSRect) -> CGFloat {
        let intersection = lhs.intersection(rhs)
        guard !intersection.isNull else {
            return 0
        }
        return intersection.width * intersection.height
    }
}
