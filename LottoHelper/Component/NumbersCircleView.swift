//
//  NumberCircleView.swift
//  LottoHelper
//
//  Created by 김정규님/Comm Client팀 on 5/14/24.
//

import SwiftUI

struct NumbersCircleView: View {
    
    var numbers: [Int]
    var plus: Int?
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(numbers.sorted(), id: \.self) { index in
                Image(systemName: "\(index).circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color.ballColor(number: index))
            }
            
            if let plus {
                Image(systemName: "plus")
                Image(systemName: "\(plus).circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color.ballColor(number: plus))
            }
        }
    }
}

#Preview {
    NumbersCircleView(numbers: [1,21,31,41,11,9], plus: 10)
}
