//
//  ContentView.swift
//  LottoHelper
//
//  Created by 김정규님/Comm Client팀 on 5/13/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    var body: some View {
        
        TabView {
            Group {
                WinNumberListView()
                    .tabItem {
                        Label("Wins", systemImage: "face.smiling.fill")
                    }
                
                NumberCheckView()
                    .padding(.vertical, 4)
                    .tabItem {
                        Label("Check", systemImage: "square.and.pencil.circle")
                    }
                
                ItemListView()
                    .tabItem {
                        Label("List", systemImage: "list.bullet.circle")
                    }
            }
            .toolbarBackground(.gray.opacity(0.1), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(.light, for: .tabBar)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
