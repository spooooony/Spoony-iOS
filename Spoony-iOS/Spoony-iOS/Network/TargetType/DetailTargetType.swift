//
//  DetatilTargetType.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/20/25.
//

import Foundation
import Moya

enum DetailTargetType {
    case getDetailReview(userId: Int, postId: Int)
    case scoopReview(userId: Int, postId: Int)
    case scrapReview(userId: Int, postId: Int)
    case unScrapReview(userId: Int, postId: Int)
}

extension DetailTargetType: TargetType {
    
    var baseURL: URL {
        guard let url = URL(string: Config.baseURL) else {
            fatalError("baseURL could not be configured")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .getDetailReview(let userId, let postId):
            return "/post/\(userId)/\(postId)"
        case .scoopReview:
            return "/post/scoop"
        case .scrapReview:
            return "/post/zzim"
        case .unScrapReview(let userId, let postId):
            return "/post/zzim/\(userId)/\(postId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getDetailReview:
            return .get
        case .scoopReview,
                .scrapReview:
            return .post
        case .unScrapReview:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getDetailReview:
            return .requestPlain
        case .scoopReview(let userId, let postId), .scrapReview(let userId, let postId):
            return .requestParameters(
                parameters: [
                    "postId": postId,
                    "userId": userId
                ],
                encoding: JSONEncoding.default
            )
        case .unScrapReview:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        return Config.defaultHeader
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
