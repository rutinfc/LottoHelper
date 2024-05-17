//
//  NumberInputView.swift
//  LottoHelper
//
//  Created by 김정규님/Comm Client팀 on 5/13/24.
//

import SwiftUI

struct NumberInputView: View {
    
    @State var checked: [Bool] = Array(repeating: false, count: LottoInfo.list.count)
    @Binding var selectedNumbers: [Int]
    
    var checkedList: [Int] {
        checked.enumerated()
            .filter({ $0.element })
            .compactMap({ numbers[$0.offset] })
    }
    
    let checkIntent = LottoInfo.CheckIntent()
    let numbers = LottoInfo.list
    let numbersColums = [ GridItem(.adaptive(minimum: 40, maximum: 40), spacing: 4) ]
    let checkColums = [ GridItem(.adaptive(minimum: 40, maximum: 40), spacing: 4) ]
    
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
                }
                .frame(width: 40, height: 40)
                
                Button {
                    self.checkIntent.save(numbers: self.selectedNumbers)
                    self.clear()
                } label : {
                    Image(systemName: "plus.app").resizable()
                }
                .frame(width: 40, height: 40)
            }
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            
            LazyVGrid(columns: numbersColums, spacing: 4){
                
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
                         
                        self.selectedNumbers = self.checkedList
                        
                    } label: {
                        
                        if let index = numbers.firstIndex(of: number), checked[index] == true {
                            Image(systemName: "\(number).circle.fill")
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: "\(number).circle")
                                .resizable()
                                .scaledToFill()
                        }
                        
                    }
                    .frame(width: 40, height: 40)
                    
                }
            }
        }
        .onChange(of: self.selectedNumbers) { oldValue, newValue in
            
            var checked = Array(repeating: false, count: LottoInfo.list.count)
            
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
        self.checked = Array(repeating: false, count: LottoInfo.list.count)
    }
}

#Preview {
    NumberInputView(selectedNumbers: .constant([Int]()))
}
