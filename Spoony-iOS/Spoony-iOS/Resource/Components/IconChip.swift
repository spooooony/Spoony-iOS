//
//  IconChip.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/14/25.
//

import SwiftUI

enum FoodType: CaseIterable {
    case korean
    case japanese
    case chinese
    case american
    case world
    case cafe
    case bar
    
    var title: String {
        switch self {
        case .korean:
            "한식"
        case .japanese:
            "일식"
        case .chinese:
            "중식"
        case .american:
            "양식"
        case .world:
            "퓨전/세계요리"
        case .cafe:
            "카페"
        case .bar:
            "주류"
        }
    }
    
    init?(title: String) {
        if let food = FoodType.allCases.first(where: { $0.title == title }) {
            self = food
        } else {
            return nil
        }
    }
}

enum Chiptype {
    case large
    case small
}

enum ChipColorType: String {
    case main
    case orange
    case pink
    case green
    case blue
    case purple
    case gray600
    case black
    case main400
    
    var textColor: Color {
        switch self {
        case .main:
                .main400
        case .orange:
                .orange400
        case .pink:
                .pink400
        case .green:
                .green400
        case .blue:
                .blue400
        case .purple:
                .purple400
        case .gray600:
                .gray600
        case .black, .main400:
                .white
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .main:
                .main0
        case .orange:
                .orange100
        case .pink:
                .pink100
        case .green:
                .green100
        case .blue:
                .blue100
        case .purple:
                .purple100
        case .gray600:
                .gray0
        case .black:
                .spoonBlack
        case .main400:
                .main400
        }
    }
}

struct IconChip: View {
    let title: String
    let foodType: FoodType?
    let chipType: Chiptype
    var color: ChipColorType
    
    var body: some View {
        HStack(spacing: 4) {
            Image(imageString)
                .resizable()
                .frame(width: 16.adjusted, height: 16.adjustedH)
            Text(title)
                .customFont(chipType == .large ? .body2sb : .caption1m)
                .foregroundStyle(color.textColor)
        }
        .padding(.vertical, chipType == .large ? 6 : 4)
        .padding(.horizontal, chipType == .large ? 14 : 10)
        .background(
            LinearGradient(
                gradient: Gradient(
                    colors: color ==
                        .black ? [
                        .spoonBlack,
                        .spoonBlack,
                        .spoonBlack,
                        .gray500
                    ] : [color.backgroundColor]
                ),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            ),
            in: RoundedRectangle(cornerRadius: 12)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(chipType == .large ? .gray100 : .clear)
        }
    }
}
// icon chip 변경하면 고칠 예정
extension IconChip {
    private var imageString: String {
        if let foodType {
            if color == .black {
                return "ic_\(foodType)_white"
            } else {
                return "ic_\(foodType)_\(color)"
            }
        } else if title == "전체" {
            if color == .black {
                return "ic_spoon_white"
            } else {
                return "ic_spoon_\(color)"
            }
        } else {
            if color == .black {
                return "ic_pin_white"
            } else {
                return "ic_pin_\(color)"
            }
        }
    }
}

#Preview {
    IconChip(title: "로컬 수저", foodType: .american, chipType: .large, color: .gray600)
}
