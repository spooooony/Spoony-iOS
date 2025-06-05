//
//  PostTargetType.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/20/25.
//

import Foundation
import Moya

enum PostTargetType {
    case getPost(postId: Int)
    case scoopPost(postId: Int)
    case scrapPost(postId: Int)
    case unScrapPost(postId: Int)
    case getMyUserInfo
    case getOtherUserInfo(userId: Int)
    case deletePost(postId: Int)
}

extension PostTargetType: TargetType {

    var baseURL: URL {
        guard let url = URL(string: Config.baseURL) else {
            fatalError("baseURL could not be configured")
        }
        return url
    }

    var path: String {
        switch self {
        case .getPost(let postId):
            return "/post/\(postId)"
        case .scoopPost:
            return "/post/scoop"
        case .scrapPost:
            return "/post/zzim"
        case .unScrapPost(let postId):
            return "/post/zzim/\(postId)"
        case .getMyUserInfo:
            return "/user"
        case .getOtherUserInfo(let userId):
            return "/user/\(userId)"
        case .deletePost(let postId):
            return "/post/\(postId)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getPost, .getMyUserInfo, .getOtherUserInfo:
            return .get
        case .scoopPost, .scrapPost:
            return .post
        case .unScrapPost, .deletePost:
            return .delete
        }
    }

    var task: Moya.Task {
        switch self {
        case .getPost, .getMyUserInfo, .getOtherUserInfo:
            return .requestPlain
        case .scoopPost(let postId), .scrapPost(let postId):
            return .requestParameters(
                parameters: [
                    "postId": postId
                ],
                encoding: JSONEncoding.default
            )
        case .unScrapPost, .deletePost:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
//        return Config.defaultHeader
        return HeaderType.auth.value
    }

    var validationType: ValidationType {
        return .successCodes
    }
}
