//
//  ContentView.swift
//  LottoHelper
//
//  Created by 김정규님/Comm Client팀 on 5/13/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    let tabModifier = TabModifier()
    
    var body: some View {
        
        NavigationSplitView {
            TabView {
                Group {
                    WinNumberListView()
                        .tabItem {
                            Label("Win Numbers", systemImage: "face.smiling.fill")
                        }
                        .navigationSplitViewColumnWidth(400)
                    
                    AnalyzeView()
                        .tabItem {
                            Label("Analyze", systemImage: "hourglass.circle")
                        }
                        .navigationSplitViewColumnWidth(400)
                    
                    NumberCheckView()
                        .padding(.vertical, 4)
                        .tabItem {
                            Label("Check", systemImage: "square.and.pencil.circle")
                        }
                        .navigationSplitViewColumnWidth(400)
                    
                    MyNumbersView()
                        .tabItem {
                            Label("My Numbers", systemImage: "list.bullet.circle")
                        }
                        .navigationSplitViewColumnWidth(400)
                }
                .modifier(self.tabModifier)
            }
        } detail: {
            Text("Select an item")
        }
    }
}

struct TabModifier: ViewModifier {
    
#if os(iOS)
    func body(content: Content) -> some View {
        content
            .toolbarBackground(.gray.opacity(0.1), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(.light, for: .tabBar)
    }
#endif
    
#if os(macOS)
    func body(content: Content) -> some View {
        content
            .frame(minWidth: 400)
    }
#endif
    
}

#Preview {
    ContentView()
        .modelContainer(for: CheckNumbers.self, inMemory: true)
}
