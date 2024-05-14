//
//  LottoInfo.swift
//  LottoHelper
//
//  Created by 김정규님/Comm Client팀 on 5/13/24.
//

import SwiftUI

struct LottoInfo {
    
    static let list = Array(1...46)
    
    static func randomNumbers(count: Int = 7) -> Set<Int> {
        
        var numbers = Set<Int>()
        
        
        while numbers.count < count {
            numbers.insert(Int.random(in: (1...46)))
        }
        
        return numbers
    }
    
    actor WinsNumberSync {
        
        var list = [WinNumbers]()
        
        func createDummy(rounds: Int) async {
            
            self.list = (1...rounds).compactMap{ round in
                var numbers = LottoInfo.randomNumbers()
                guard let plus = numbers.popFirst() else {
                    return nil
                }
                return WinNumbers(round: round, numbers: Array(numbers), plus: plus)
            }
        }
    }
    
    static let winsNumber = WinsNumberSync()
    
    class WinsModel: ObservableObject {
        
        @Published var list = [WinNumbers]()
        
        func createDummy(rounds: Int) {
            
            Task {
                await LottoInfo.winsNumber.createDummy(rounds: rounds)
                let list = await LottoInfo.winsNumber.list
                
                Task { @MainActor in
                    self.list = list
                }
            }
        }
    }
}

