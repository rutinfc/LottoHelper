//
//  NumberCheckView.swift
//  LottoHelper
//
//  Created by 김정규님/Comm Client팀 on 5/14/24.
//

import SwiftUI

struct NumberCheckView: View {
    
    @State var selectedNumbers = [Int]()
    
    var body: some View {
        VStack {
            NumberInputView(selectedNumbers: $selectedNumbers)
                .padding(.vertical, 8)
            
            HStack {
                Spacer()
                Button {
                    self.selectedNumbers = Array(LottoInfo.randomNumbers(count: 6))
                } label: {
                    Image(systemName: "pencil.and.outline")
                        .resizable()
                        .frame(width:30, height: 30)
                    Text("Auto").font(.headline)
                }
            }
            
            Rectangle()
                .foregroundColor(Color.lineColor1)
                .frame(maxWidth: .infinity)
                .frame(height: 4)
                .cornerRadius(2)
                .padding(.horizontal, 4)
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

#Preview {
    NumberCheckView()
}
