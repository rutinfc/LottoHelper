//
//  LottoHelperApp.swift
//  LottoHelper
//
//  Created by 김정규님/Comm Client팀 on 5/13/24.
//

import SwiftUI
import SwiftData

@main
struct LottoHelperApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(LottoInfo.Container.shared.modelContainer)
    }
}
