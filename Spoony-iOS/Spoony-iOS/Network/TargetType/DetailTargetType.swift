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
    case scoopReview
    case scrapReview
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
        case .scoopReview,
                .scrapReview:
            return .requestPlain
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
