//
//  Color+.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import Foundation
import SwiftUI

struct AppColor {
    // Main Scale
    static let main0 = Color(hex: "FFEFEC")
    static let main100 = Color(hex: "FFCEC6")
    static let main200 = Color(hex: "FF9785")
    static let main300 = Color(hex: "FF755E")
    static let main400 = Color(hex: "FF5235")
    static let main500 = Color(hex: "E1482E")
    static let main600 = Color(hex: "BE3A24")
    static let main700 = Color(hex: "962D1C")
    static let main800 = Color(hex: "6E2317")
    static let main900 = Color(hex: "4E150B")
    
    // Point Colors
    static let orange100 = Color(hex: "FFE1D0")
    static let orange400 = Color(hex: "FF7E35")
    static let pink100 = Color(hex: "FFE4E5")
    static let pink400 = Color(hex: "FF7E84")
    static let green100 = Color(hex: "D3F4EB")
    static let green400 = Color(hex: "00CB92")
    static let blue100 = Color(hex: "DCE5FE")
    static let blue400 = Color(hex: "6A92FF")
    static let purple100 = Color(hex: "EEE3FD")
    static let purple400 = Color(hex: "AD75F9")
    
    // Gray Scale
    static let gray0 = Color(hex: "F7F7F8")
    static let gray100 = Color(hex: "EAEBEC")
    static let gray200 = Color(hex: "DBDCDF")
    static let gray300 = Color(hex: "C2C4C8")
    static let gray400 = Color(hex: "989BA2")
    static let gray500 = Color(hex: "878A93")
    static let gray600 = Color(hex: "5A5C63")
    static let gray700 = Color(hex: "46474C")
    static let gray800 = Color(hex: "333438")
    static let gray900 = Color(hex: "292A2D")
    
    // State
    static let error400 = Color(hex: "FF364A")
    
    // Basic
    static let white = Color(hex: "FFFFFF")
    static let spoonBlack = Color(hex: "171719")
    
    // Gradation
    static let blackgrad1 = Color(hex: "171719")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
