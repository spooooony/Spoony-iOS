//
//  CheckNicknameRepository.swift
//  Spoony
//
//  Created by 최주리 on 10/12/25.
//

import Foundation

struct CheckNicknameRepository: CheckNicknameInterface {
    private let myPageService: MypageServiceProtocol
    
    init(myPageService: MypageServiceProtocol) {
        self.myPageService = myPageService
    }
    
    func checkNicknameDuplicate(nickname: String) async throws -> Bool {
        return try await myPageService.nicknameDuplicationCheck(nickname: nickname)
    }
}

struct MockChekcNicknameRepository: CheckNicknameInterface {
    func checkNicknameDuplicate(nickname: String) async throws -> Bool {
        return true
    }
}

