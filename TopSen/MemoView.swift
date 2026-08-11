//
//  MemoView.swift
//  TopSen
//

import SwiftUI

struct MemoView: View {
    @ObservedObject var store: MemoStore

    var body: some View {
        TextEditor(text: $store.text)
            .font(.body)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .padding(.horizontal, 10)
            .padding(.top, 28)
            .padding(.bottom, 8)
            .accessibilityLabel("メモ")
            .accessibilityIdentifier("memoEditor")
            .background(.ultraThinMaterial.opacity(0.78))
    }
}
