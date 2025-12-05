//
//  NicknameErrorTypeModel.swift
//  Spoony
//
//  Created by 최주리 on 10/10/25.
//

import SwiftUI

struct NicknameErrorTypeModel {
    let type: NicknameErrorType
    let errorMessage: String?
    let fontColor: Color
    let errorColor: Color
    let icon: Image?
}

extension NicknameErrorTypeModel {
    static func typeToModel(from type: NicknameErrorType) -> Self {
        switch type {
        case .duplicateNicknameError:
                .init(
                    type: type,
                    errorMessage: "이미 사용 중인 닉네임이에요",
                    fontColor: .error400,
                    errorColor: .error400,
                    icon: Image(.icErrorRed)
                )
        case .minimumInputError:
                .init(
                    type: type,
                    errorMessage: "닉네임은 필수예요",
                    fontColor: .error400,
                    errorColor: .error400,
                    icon: nil
                )
        case .maximumInputError:
                .init(
                    type: type,
                    errorMessage: "10자 이하로 입력해 주세요",
                    fontColor: .error400,
                    errorColor: .error400,
                    icon: nil
                )
        case .emojiError:
                .init(
                    type: type,
                    errorMessage: "닉네임은 한글, 영문, 숫자만 사용할 수 있어요",
                    fontColor: .error400,
                    errorColor: .error400,
                    icon: nil
                )
        case .avaliableNickname:
                .init(
                    type: type,
                    errorMessage: "사용 가능한 닉네임이에요",
                    fontColor: .green400,
                    errorColor: .green400,
                    icon: Image(.icCheckGreen)
                )
        case .noError, .initial:
                .init(
                    type: type,
                    errorMessage: nil,
                    fontColor: .gray500,
                    errorColor: .gray100,
                    icon: nil
                )
        }
    }
}
