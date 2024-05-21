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

    @StateObject var analyze = LottoInfo.Analyze()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    analyze.reload()
                }
        }
        .modelContainer(LottoInfo.Container.shared.modelContainer)
        .environmentObject(analyze)
    }
}
