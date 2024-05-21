//
//  NumberInputView.swift
//  LottoHelper
//
//  Created by 김정규님/Comm Client팀 on 5/13/24.
//

import SwiftUI

struct NumberInputModifier: ViewModifier {
    
    @Binding var selectedNumbers: [Int]
    @Binding var presentFlag: Bool
    
    func body(content: Content) -> some View {
#if os(iOS)
        content
        .fullScreenCover(isPresented: $presentFlag, content: {
            NumberInputView(selectedNumbers: $selectedNumbers, presentFlag: $presentFlag)
        })
#else
        content
        .sheet(isPresented: $presentFlag, content: {
            NumberInputView(selectedNumbers: $selectedNumbers, presentFlag: $presentFlag)
                .frame(idealWidth: 450, idealHeight: 400)
        })
#endif
    }
    
}

struct NumberInputView: View {
    
    @State var checked: [Bool] = Array(repeating: false, count: LottoInfo.numberList.count)
    @State var currentNumbers = [Int]()
    @Binding var selectedNumbers: [Int]
    @Binding var presentFlag: Bool
    
    var checkedList: [Int] {
        checked.enumerated()
            .filter({ $0.element })
            .compactMap({ numbers[$0.offset] })
    }
    
    let numbers = LottoInfo.numberList
    let numbersColums = [ GridItem(.adaptive(minimum: 40, maximum: 40), spacing: 0) ]
    let checkColums = [ GridItem(.adaptive(minimum: 40, maximum: 40), spacing: 4) ]
    
    var disableApply: Bool {
        
        if self.currentNumbers.count < LottoInfo.maxCount {
            return true
        }
        
        if self.selectedNumbers == self.currentNumbers {
            return true
        }
        
        return false
    }
    
    var body: some View {
        
        VStack(spacing: 8) {
            
            HStack {
                ZStack(alignment: .center) {
                    LazyVGrid(columns: checkColums) {
                        ForEach(checkedList, id: \.self) { number in
                            Image(systemName: "\(number).circle.fill")
                                .resizable()
                                .scaledToFill()
                                .foregroundColor(Color.ballColor(number: number))
                        }
                    }
                    .frame(maxWidth:.infinity, minHeight: 60)
                    .frame(alignment: .center)
                    .padding(.horizontal, 4)
                }
                .border(Color.lineColor1, width: 4)
                .cornerRadius(8)
                
                Button {
                    self.clear()
                } label : {
                    Image(systemName: "clear")
                        .resizable()
                        .foregroundColor(.red)
                        .frame(width: 30, height: 30, alignment: .center)
                }
                .buttonStyle(.plain)
                
                Button {
                    self.currentNumbers = Array(LottoInfo.randomNumbers(exception: self.currentNumbers)).sorted()
                } label: {
                    Image(systemName: "gearshape.arrow.triangle.2.circlepath")
                        .resizable()
                        .scaledToFit()
                        .frame(width:30, height: 30)
                }
                .buttonStyle(.plain)
                
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            
            LazyVGrid(columns: numbersColums, spacing: 8){
                
                ForEach(numbers, id: \.self) { number in
                    Button {
                        
                        if let index = numbers.firstIndex(of: number) {
                            
                            let check = !checked[index]
                            if check, checkedList.count < 6 {
                                checked[index] = check
                            } else if check == false {
                                checked[index] = check
                            }
                        }
                         
                        self.currentNumbers = self.checkedList.sorted()
                        
                    } label: {
                        
                        if let index = numbers.firstIndex(of: number), checked[index] == true {
                            Image(systemName: "\(number).circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                        } else {
                            Image(systemName: "\(number).circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                        
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            Spacer()
            
            HStack {
                Button {
                    self.presentFlag.toggle()
                } label: {
                    Text("Cancel")
                        .frame(height: 30)
                        .frame(maxWidth: .infinity).fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    self.selectedNumbers = self.currentNumbers
                    self.presentFlag.toggle()
                } label: {
                    Text(self.selectedNumbers.count == 0 ? "Add" : "Modify")
                        .frame(height: 30)
                        .frame(maxWidth: .infinity).fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                }
                .disabled(self.disableApply)
                .buttonStyle(.borderedProminent)
                
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
        }
        .onAppear {
            self.currentNumbers = self.selectedNumbers
        }
        .onChange(of: self.currentNumbers) { oldValue, newValue in
            
            var checked = Array(repeating: false, count: LottoInfo.numberList.count)
            
            newValue.forEach { number in
                if let index = numbers.firstIndex(of: number) {
                    checked[index] = true
                }
            }
            
            if self.checked != checked {
                self.checked = checked
            }
        }
    }
    
    func clear() {
        self.currentNumbers = [Int]()
    }
}

#Preview {
    NumberInputView(selectedNumbers: .constant([Int]()), presentFlag: .constant(false))
}
