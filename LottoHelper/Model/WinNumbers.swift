//
//  WinNumbers.swift
//  LottoHelper
//
//  Created by JK Kim on 5/17/24.
//

import Foundation
import SwiftData

@Model
final class WinNumbers {
    
    var round: Int
    var numbers: [Int]
    var plus: Int
    
    init(round: Int, numbers: [Int], plus: Int) {
        self.round = round
        self.numbers = numbers
        self.plus = plus
    }
}
