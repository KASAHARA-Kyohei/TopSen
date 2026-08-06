//
//  MemoStore.swift
//  TopSen
//

import Combine
import Foundation

@MainActor
final class MemoStore: ObservableObject {
    static let defaultKey = "memo.text"

    @Published var text: String {
        didSet {
            defaults.set(text, forKey: key)
        }
    }

    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = "memo.text") {
        self.defaults = defaults
        self.key = key
        text = defaults.string(forKey: key) ?? ""
    }

    func clear() {
        text = ""
    }
}
