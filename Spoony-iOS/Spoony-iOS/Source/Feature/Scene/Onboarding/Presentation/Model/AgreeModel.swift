//
//  AgreeTypeModel.swift
//  Spoony
//
//  Created by 최주리 on 10/10/25.
//

struct AgreeModel {
    let type: AgreeType
    let title: String
    let hasURL: Bool
}

extension AgreeModel {
    static func typeToModel(from type: AgreeType) -> Self {
        let title: String
        switch type {
        case .age:
            title = "만 14세 이상입니다."
        case .termsOfUse:
            title = "스푸니 서비스 이용약관"
        case .privacyPolicy:
            title = "개인정보 처리 방침"
        case .locationPolicy:
            title = "위치기반 서비스 이용 약관"
        }
        
        return .init(type: type, title: title, hasURL: type.hasURL)
    }
}
