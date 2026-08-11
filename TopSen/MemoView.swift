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
            .glassEffect(
                .clear.interactive(),
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.14), lineWidth: 0.6)
                    .allowsHitTesting(false)
            }
    }
}
