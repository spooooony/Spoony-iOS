//
//  ExploreTargetType.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/20/25.
//

import Foundation
import Moya

enum ExploreTargetType {
    case getUserFeeds(
        categoryId: Int,
        location: String,
        sort: SortType
    )
    case reportPost(report: ReportRequest)
    case getCategories
    
    case getFeedList
    case getFollowingFeedList
    
    case searchPost(query: String)
}

extension ExploreTargetType: TargetType {
    
    var baseURL: URL {
        guard let url = URL(string: Config.baseURL) else {
            fatalError("baseURL could not be configured")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .getUserFeeds(let categoryId, _, _):
            return "/feed/\(categoryId)"
        case .reportPost:
            return "/report"
        case .getCategories:
            return "/post/categories"
        case .getFeedList:
            return "/feed"
        case .getFollowingFeedList:
            return "/feed/following"
        case .searchPost:
            return "/post/search"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getUserFeeds,
                .getCategories, .getFeedList, .getFollowingFeedList, .searchPost:
            return .get
        case .reportPost:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case let .getUserFeeds(_, location, filter):
            let params: [String: String] = [
                "query": location,
                "sortBy": filter.rawValue
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .getCategories, .getFeedList, .getFollowingFeedList:
            return .requestPlain
        case .reportPost(let report):
            return .requestCustomJSONEncodable(report, encoder: JSONEncoder())
        case .searchPost(let query):
            return .requestParameters(parameters: [
                "query": query
            ], encoding: URLEncoding.default)
        }
    }
    
    // TODO: 헤더타입 바꾸기
    var headers: [String: String]? {
        return Config.defaultHeader
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
