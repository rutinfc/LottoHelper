//
//  NumberBarChartView.swift
//  LottoHelper
//
//  Created by JK Kim on 6/29/24.
//

import SwiftUI
import Charts

struct NumberBarChartView: View {
    
    var numberTotalCount: [LottoInfo.Analyze.AvgNumberModel]
    var avgPercent: Float
    var maxPercent: Float {
        min((self.numberTotalCount.compactMap({$0.percent}).sorted().last ?? 0) + 3, 100)
    }
    
    var numberList: [String] {
        return self.numberTotalCount.compactMap({ String($0.number) })
    }
    
    var body: some View {
        GroupBox {
            Chart(numberTotalCount) { item in
                
                BarMark(xStart: .value("Percent", 0),
                        xEnd: .value("Percent", item.percent),
                        y: .value("Number", String(item.number))
                )
                .foregroundStyle(by: .value("Number", item.number))
                .annotation(position: .overlay, alignment: .top, spacing: 0) {
                    Text("\(item.percent)")
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        .padding(.top, 2)
                }
                RuleMark(x: .value("평균 당첨 비율", avgPercent))
                    .foregroundStyle(.red.opacity(0.3))
            }
            .chartScrollableAxes(.vertical)
            .chartYVisibleDomain(length: min(numberList.count, 12))
            .chartForegroundStyleScale(range: colors(numbers: numberTotalCount))
            .chartXScale(domain: 0...self.maxPercent + 1)
            .chartXAxisLabel(position: .bottom, alignment: .center, content: {
                Text("당첨 비율")
            })
            .chartYAxisLabel(position: .leading, content: {
                Text("번호")
            })
            .chartYAxis {
                AxisMarks(preset:.aligned, position: .leading, values: numberList) { value in
                    AxisValueLabel(verticalSpacing: 1)
                }
            }
        }
        
        .padding(.all, 8)
    }
    
    func colors(numbers: [LottoInfo.Analyze.AvgNumberModel]) -> [Color] {
        
        return numbers.compactMap { model in
            Color.ballColor(number:model.number)
        }
    }
}

#Preview {
    NumberBarChartView(
        numberTotalCount:
            [LottoInfo.Analyze.AvgNumberModel(number: 1, count: 0, percent: 10),
             LottoInfo.Analyze.AvgNumberModel(number: 11, count: 1, percent: 11),
             LottoInfo.Analyze.AvgNumberModel(number: 21, count: 2, percent: 12),
             LottoInfo.Analyze.AvgNumberModel(number: 31, count: 3, percent: 13),
             LottoInfo.Analyze.AvgNumberModel(number: 41, count: 4, percent: 15)]
        , avgPercent: 12
    )
}
