//
//  RoundNumbersView.swift
//  LottoHelper
//
//  Created by 김정규님/Comm Client팀 on 5/23/24.
//

import SwiftUI

struct RoundNumbersItemView: View {
    
    var round: Int? = nil
    var numbers: [Int]
    var timestamp: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            if let round {
                Text("\(round)")
                    .frame(width: 40, alignment: .leading)
                    .font(.subheadline)
                    .padding(.trailing, 8)
            }
            
            NumbersCircleView(numbers: numbers)
            Text(timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                .font(.caption)
        }
    }
}

#Preview {
    RoundNumbersItemView(round: 1, numbers: [1,2,3,4,5,6], timestamp: Date())
}
