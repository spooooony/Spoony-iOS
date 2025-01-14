//
//  IconChip.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/14/25.
//

import SwiftUI

enum FoodType {
    case korean
    case japanese
    case chinese
    case american
    case world
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
        case .bar:
            "주류"
        }
    }
}

enum Chiptype {
    case large
    case small
}

struct IconChip: View {
    let foodType: FoodType
    let chipType: Chiptype
    var color: Color?
    
    init(foodType: FoodType, chipType: Chiptype, color: Color? = nil) {
        self.foodType = foodType
        self.chipType = chipType
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(.icBarBlue)
            Text(foodType.title)
                .font(chipType == .large ? .body2sb : .caption1m)
                .foregroundStyle(.gray600)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 16)
        .background(.gray0, in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.gray100)
        }
    }
}

extension IconChip {
    private var image: ImageResource {
        switch foodType {
        case .korean where chipType == .large:
            <#code#>
        case .japanese:
            <#code#>
        case .chinese:
            <#code#>
        case .american:
            <#code#>
        case .world:
            <#code#>
        case .bar:
            <#code#>
        }
    }
}

#Preview {
    IconChip(foodType: .american, chipType: .large)
}
