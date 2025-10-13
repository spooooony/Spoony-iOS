//
//  CheckNicknameInterface.swift
//  Spoony
//
//  Created by 최주리 on 10/12/25.
//

protocol CheckNicknameInterface {
    func checkNicknameDuplicate(nickname: String) async throws -> Bool
}
