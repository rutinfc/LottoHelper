//
//  NumberCount.swift
//  LottoHelper
//
//  Created by JK Kim on 5/21/24.
//

import Foundation
import SwiftData

@Model
final class NumbersTotalCount {
    
    var lastRound: Int
    var count: [Int: Int]
    
    init(lastRound: Int, count: [Int : Int]) {
        self.lastRound = lastRound
        self.count = count
    }
}
