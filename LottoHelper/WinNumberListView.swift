//
//  WinNumberListView.swift
//  LottoHelper
//
//  Created by 김정규님/Comm Client팀 on 5/14/24.
//

import SwiftUI

struct WinNumberListView: View {
    
    @State private var showDummyAlert = false
    @State private var dummyRounds: String = ""
    @StateObject private var winsInfo = LottoInfo.WinsModel()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Win Numbers").font(.title)
                Spacer()
                Button("Dummy") {
                    self.showDummyAlert.toggle()
                }
                .alert("Create Dummy", isPresented: $showDummyAlert) {
                    TextField("Create Rounds", text: $dummyRounds)
                    Button("Create") {
                        if let round = Int(dummyRounds) {
                            winsInfo.createDummy(rounds: round)
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Create random number with Input Round count")
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 80)
            
            List {
                ForEach(winsInfo.list, id: \.self) { item in
                    HStack {
                        Text("\(item.round)")
                            .frame(width: 40, alignment: .leading)
                            .font(.subheadline)
                            .padding(.trailing, 8)
                        NumbersCircleView(numbers: item.numbers, plus: item.plus)
                        
                        Spacer()
                    }
                    
                }
            }
        }.onAppear() {
            if winsInfo.list.count == 0 {
                winsInfo.createDummy(rounds: 100)
            }
        }
    }
}

#Preview {
    WinNumberListView()
}
