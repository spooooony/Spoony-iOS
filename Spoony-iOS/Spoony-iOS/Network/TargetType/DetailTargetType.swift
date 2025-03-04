//
//  DetatilTargetType.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/20/25.
//

import Foundation
import Moya

enum DetailTargetType {
    case getDetailReview(postId: Int)
    case scoopReview(postId: Int)
    case scrapReview(postId: Int)
    case unScrapReview(postId: Int)
    case getUserInfo
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
        case .getDetailReview(let postId):
            return "/post/\(postId)"
        case .scoopReview:
            return "/post/scoop"
        case .scrapReview:
            return "/post/zzim"
        case .unScrapReview(let postId):
            return "/post/zzim/\(postId)"
        case .getUserInfo:
            return "/user/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getDetailReview, .getUserInfo:
            return .get
        case .scoopReview, .scrapReview:
            return .post
        case .unScrapReview:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getDetailReview, .getUserInfo:
            return .requestPlain
        case .scoopReview(let postId), .scrapReview(let postId):
            return .requestParameters(
                parameters: [
                    "postId": postId
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
