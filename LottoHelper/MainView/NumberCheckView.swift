//
//  NumberCheckView.swift
//  LottoHelper
//
//  Created by 김정규님/Comm Client팀 on 5/14/24.
//

import SwiftUI

struct NumberCheckView: View {
    
    let checkIntent = LottoInfo.CheckIntent()
    private let modifier = TextFieldStyle()
    
    @Environment(\.modelContext) private var modelContext
    
    @State var presentInput: Bool = false
    @State var selectedNumbers = [Int]()
    @State var round: String = ""
    @State var selectedList = [CheckNumbers]()
    @State var callbackItem = CheckNumbers(round: 0, numbers: [Int]())
    
    var roundNumber: Int {
        return Int(self.round) ?? 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Number Check").font(.title)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 60)
            
            HStack(spacing: 12) {
                HStack {
                    Text("Round")
                    TextField("Round", text: $round)
                        .modifier(modifier)
                        .onChange(of: round) { oldValue, newValue in
                            self.round = Int(newValue)?.formatted() ?? oldValue
                        }
                }
                .padding(.leading, 8)
                
                Spacer()
                Button {
                    self.selectedNumbers = Array(LottoInfo.randomNumbers())
                } label : {
                    Image(systemName: "gearshape.arrow.triangle.2.circlepath")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30, alignment: .center)
                }
                .buttonStyle(.plain)
                
                Button {
                    self.presentInput.toggle()
                } label : {
                    Image(systemName: "hand.point.up.braille")
                        .resizable().scaledToFit()
                        .frame(width: 30, height: 30, alignment: .center)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
            
            #if os(iOS)
            Divider()
            #endif

            List {
                ForEach(selectedList) { item in
                    HStack {
                        NavigationLink {
                            NumbersDetailView(item: item)
                        } label: {
                            RoundNumbersItemView(numbers: item.numbers, timestamp: item.timestamp)
                            .padding(.vertical, 8)
                        }
                    }
                    .contextMenu {
                        Button {
                            self.createNumberException(numbers: item.numbers)
                        } label: {
                            Image(systemName: "bag.badge.minus")
                            Text("Create numbers except this number")
                        }
                        .frame(width: 40, height: 40)
                        
                        Button {
                            self.delete(item: item)
                        } label: {
                            Image(systemName: "trash")
                            Text("Remove")
                        }
                        .frame(width: 40, height: 40)
                    }
                    .swipeActions {
                        Button {
                            self.delete(item: item)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .tint(.red)
                        
                        Button {
                            self.createNumberException(numbers: item.numbers)
                        } label: {
                            Image(systemName: "bag.badge.minus")
                        }
                        .tint(.green)
                    }
                    .onChange(of: item.numbers) { oldValue, newValue in
                        guard newValue.count == 0 else {
                            return
                        }
                        
                        self.selectedList.removeAll(where: {$0 == item})
                    }
                }
            }
            .safeAreaInset(edge: .bottom, content: {
                
                if self.selectedList.count == 0 {
                    EmptyView()
                } else {
                    HStack {
                        Button {
                            self.clear()
                        } label: {
                            Text("Clear")
                                .frame(height: 30)
                                .frame(maxWidth: .infinity).fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button {
                            
                            self.selectedList.forEach { model in
                                modelContext.insert(model)
                            }
                            self.clear()
                            
                        } label: {
                            Text("Apply")
                                .frame(height: 30)
                                .frame(maxWidth: .infinity).fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                        }
                        .buttonStyle(.borderedProminent)
                        
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                }
                
            })
            .scrollDismissesKeyboard(.immediately)
            .listStyle(.plain)
        }
        .onChange(of: self.selectedNumbers, { oldValue, newValue in
            
            guard newValue.count == 6 else {
                return
            }
            
            let numbers = CheckNumbers(round: self.roundNumber, numbers: newValue)
            selectedList.append(numbers)
            self.selectedNumbers = [Int]()
        })
        .modifier(NumberInputModifier(selectedNumbers: $selectedNumbers, presentFlag: $presentInput))
        .onAppear {
            self.round = (checkIntent.lastRound + 1).formatted()
        }
        .padding(.horizontal, 4)
    }
    
    private func delete(item: CheckNumbers) {
        withAnimation {
            self.selectedList.removeAll(where: { $0 == item })
        }
    }
    
    private func clear() {
        self.selectedList.removeAll()
    }
    
    private func createNumberException(numbers: [Int]) {
        
    }
}

private struct TextFieldStyle: ViewModifier {
    
    func body(content: Content) -> some View {
#if os(iOS)
        content.keyboardType(.numberPad).autocorrectionDisabled()
#else
        content.autocorrectionDisabled()
#endif
        
    }
}

#Preview {
    NumberCheckView()
}
