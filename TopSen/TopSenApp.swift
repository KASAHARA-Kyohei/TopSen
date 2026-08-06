//
//  TopSenApp.swift
//  TopSen
//
//  Created by 笠原恭平 on 2026/08/06.
//

import SwiftUI

@main
struct TopSenApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
