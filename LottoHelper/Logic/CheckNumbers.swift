//
//  Item.swift
//  LottoHelper
//
//  Created by 김정규님/Comm Client팀 on 5/13/24.
//

import Foundation
import SwiftData

@Model
final class CheckNumbers {
    
    var round: Int
    var numbers: [Int]
    var timestamp: Date
    
    init(round: Int, numbers: [Int], timestamp: Date) {
        self.round = round
        self.numbers = numbers
        self.timestamp = timestamp
    }
}
