//
//  WinNumberListView.swift
//  LottoHelper
//
//  Created by 김정규님/Comm Client팀 on 5/14/24.
//

import SwiftUI
import SwiftData

struct WinNumberListView: View {
    
    @State private var showDummyAlert = false
    @State private var dummyRounds: String = ""
    
    private var winIntent: LottoInfo.WinIntent
    @Environment(\.modelContext) private var context
    @Query(sort: \WinNumbers.round) private var list: [WinNumbers]
    
    private var didSavePublisher: NotificationCenter.Publisher {
        NotificationCenter.default
            .publisher(for: ModelContext.willSave, object: self.context)
    }
    
    init() {
        self.winIntent = LottoInfo.WinIntent()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Win Numbers").font(.title)
                Spacer()
                Button("Add") {
                    self.winIntent.add()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Clear") {
                    self.winIntent.removeAll()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Dummy") {
                    self.showDummyAlert.toggle()
                }
                .buttonStyle(.borderedProminent)
                .alert("Create Dummy", isPresented: $showDummyAlert) {
                    TextField("Create Rounds", text: $dummyRounds)
                    Button("Create") {
                        if let round = Int(dummyRounds) {
                            self.winIntent.createDummy(rounds: round)
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Create random number with Input Round count")
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 60)
            
            List {
                ForEach(list, id: \.self) { item in
                    HStack {
                        Text("\(item.round)")
                            .frame(width: 40, alignment: .leading)
                            .font(.headline)
                            .padding(.trailing, 8)
                        NumbersCircleView(numbers: item.numbers, plus: item.plus)
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(.plain)
        }
        .onReceive(self.didSavePublisher, perform: { _ in
            print("didSavePublisher working?")
        })
        .onAppear() {
            if self.list.count == 0 {
                self.winIntent.createDummy(rounds: 100)
            }
        }
    }
}

#Preview {
    WinNumberListView()
}
