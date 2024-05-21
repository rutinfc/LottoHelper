//
//  NumbersDetailView.swift
//  LottoHelper
//
//  Created by JK Kim on 5/29/24.
//

import SwiftUI

struct NumbersDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var analyze: LottoInfo.Analyze
    
    @State var presentFlag: Bool = false
    @State var selectedNumbers = [Int]()
    
    var filterModel : [LottoInfo.Analyze.AvgNumberModel] {
        analyze.avgInfo.numbers.filter({ self.selectedNumbers.contains($0.number) })
    }
    var item: CheckNumbers
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                NumbersCircleView(numbers: item.numbers)
                Spacer()
            }
            ScrollView {
                
                LazyVStack(pinnedViews: .sectionHeaders) {
                    Section {
                        NumberBarChartView(numberTotalCount: filterModel, avgPercent: analyze.avgInfo.totalPercent)
                            .frame(height: 300)
                    } header: {
                        Text("평균 당첨비율 : \(analyze.avgInfo.totalPercent)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    }

                }
                
                Spacer()
            }
        }
        .onAppear {
            self.selectedNumbers = item.numbers
            
//            self.
        }
        .onChange(of: self.item, { oldValue, newValue in
            self.selectedNumbers = newValue.numbers
        })
        .onChange(of: selectedNumbers, { oldValue, newValue in
            guard self.item.numbers != newValue else {
                return
            }
            
            self.item.numbers = newValue
        })
        .modifier(NavigationToolbarModifier(buttonViews: {
            HStack {
                Button {
                    self.presentFlag.toggle()
                } label : {
                    Image(systemName: "hand.point.up.braille")
                        .resizable().scaledToFit()
                }
                
                Button {
                    self.item.numbers = [Int]()
                    self.dismiss()
                } label: {
                    Image(systemName: "trash").resizable().scaledToFit()
                }
            }
        }))
        .modifier(NumberInputModifier(selectedNumbers: $selectedNumbers, presentFlag: $presentFlag))
        .navigationTitle("Round \(item.round)")
        .padding(.all, 16)
    }
}
