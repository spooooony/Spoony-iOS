//
//  FollowTargetType.swift
//  Spoony-iOS
//
//  Created by 이명진 on 5/5/25.
//

import Foundation
import Moya

enum FollowTargetType {
    case follow(targetUserId: Int)
    case unfollow(targetUserId: Int)
    
    case fetchMyFollowings
    case fetchFollowings(targetUserId: Int)
    
    case fetchMyFollowers
    case fetchFollowers(targetUserId: Int)
}

extension FollowTargetType: TargetType {
    var baseURL: URL {
        guard let url = URL(string: Config.baseURL) else {
            fatalError("baseURL could not be configured")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .follow, .unfollow:
            return "/user/follow"
        case .fetchMyFollowings:
            return "/user/followings"
        case .fetchFollowings(let targetUserId):
            return "/user/followings/\(targetUserId)"
        case .fetchMyFollowers:
            return "/user/followers"
        case .fetchFollowers(let targetUserId):
            return "/user/followers/\(targetUserId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .follow:
            return .post
        case .unfollow:
            return .delete
        case .fetchMyFollowings, .fetchFollowings, .fetchMyFollowers, .fetchFollowers:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .follow(let targetUserId), .unfollow(let targetUserId):
            return .requestParameters(
                parameters: ["targetUserId": targetUserId],
                encoding: JSONEncoding.default
            )
        case .fetchMyFollowings, .fetchFollowings, .fetchMyFollowers, .fetchFollowers:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        return HeaderType.auth.value
//        return Config.defaultHeader
        
    }
}
