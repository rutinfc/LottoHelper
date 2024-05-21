//
//  Analyze.swift
//  LottoHelper
//
//  Created by JK Kim on 5/21/24.
//

import SwiftUI

struct AnalyzeView: View {
    
    @EnvironmentObject var analyze: LottoInfo.Analyze
    
    var body: some View {
        VStack {
            HStack {
                Text("Analyze").font(.title)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 60)
            
            List {
                NavigationLink {
                    
                    self.numberCountView

                } label: {
                    Text("번호별 당첨 비율").padding(.vertical, 8)
                }
            }
            
        }
    }
    
    var numberCountView: some View {
        VStack(alignment: .leading) {
            NumberBarChartView(numberTotalCount: analyze.avgInfo.numbers, avgPercent: analyze.avgInfo.totalPercent)
        }
        .navigationTitle("평균 당첨 비율 : \(analyze.avgInfo.totalPercent)")
    }
}

#Preview {
    
    Group {
        AnalyzeView()
    }
    
}
