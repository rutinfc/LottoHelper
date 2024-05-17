//
//  ColorExtension.swift
//  LottoHelper
//
//  Created by 김정규님/Comm Client팀 on 5/14/24.
//

import SwiftUI

extension Color {
    
    static func ballColor(number: Int) -> Color  {
        
        if number > 0 && number <= 10 {
            return Color.ball10
        } else if number > 10 && number <= 20 {
            return Color.ball20
        } else if number > 20 && number <= 30 {
            return Color.ball30
        } else if number > 30 && number <= 40 {
            return Color.ball40
        } else {
            return Color.ball50
        }
    }
}
