//
//  NavigationToolbarModifier.swift
//  LottoHelper
//
//  Created by JK Kim on 5/29/24.
//

import SwiftUI

struct NavigationToolbarModifier<Button: View>: ViewModifier {
    
    private let buttonViews: () -> Button
    
    init(buttonViews: @escaping () -> Button) {
        self.buttonViews = buttonViews
    }
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    self.buttonViews()
//                    Button("Add") {
//                        self.info.add()
//                    }
//                    .buttonStyle(.borderedProminent)
                }
                #else
                ToolbarItem(placement: .automatic) {
                    self.buttonViews()
//                    Button("Add") {
//                        self.info.add()
//                    }
//                    .buttonStyle(.borderedProminent)
                }
                #endif
            }
    }
}
