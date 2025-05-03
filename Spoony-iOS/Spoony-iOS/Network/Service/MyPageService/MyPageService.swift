//
//  MyPageService.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/3/25.
//

import Foundation

import Moya

protocol MypageServiceProtocol {
    func getProfileInfo() async throws -> UserProfileResponse
    func nicknameDuplicationCheck(nickname: String) async throws -> Bool
    func getProfileImages() async throws -> ProfileImageResponse
}

final class MyPageService: MypageServiceProtocol {
    private let provider = Providers.myPageProvider
    
    func getProfileInfo() async throws -> UserProfileResponse {
        return try await withCheckedThrowingContinuation { continuatioin in
            provider.request(.getProfileInfo) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<UserProfileResponse>.self)
                        guard let data = responseDto.data else { return }
                        
                        continuatioin.resume(returning: data)
                    } catch {
                        continuatioin.resume(throwing: error)
                    }
                case .failure(let error):
                    continuatioin.resume(throwing: error)
                }
            }
        }
    }
    
    func nicknameDuplicationCheck(nickname: String) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuatioin in
            provider.request(.getProfileInfo) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<Bool>.self)
                        guard let data = responseDto.data else { return }
                        
                        continuatioin.resume(returning: data)
                    } catch {
                        continuatioin.resume(throwing: error)
                    }
                case .failure(let error):
                    continuatioin.resume(throwing: error)
                }
            }
        }
    }
    
    func getProfileImages() async throws -> ProfileImageResponse {
        return try await withCheckedThrowingContinuation { continuatioin in
            provider.request(.getProfileInfo) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<ProfileImageResponse>.self)
                        guard let data = responseDto.data else { return }
                        
                        continuatioin.resume(returning: data)
                    } catch {
                        continuatioin.resume(throwing: error)
                    }
                case .failure(let error):
                    continuatioin.resume(throwing: error)
                }
            }
        }
    }
}
