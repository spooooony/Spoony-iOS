//
//  ExploreTargetType.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/20/25.
//

import Foundation
import Moya

enum ExploreTargetType {
    case reportPost(report: PostReportRequest)
    case reportUser(report: UserReportRequest)
    
    case getCategories
    
    case getFilteredFeedList(FeedFilteredRequest)
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
        case .reportPost:
            return "/report/post"
        case .reportUser:
            return "/report/user"
        case .getCategories:
            return "/post/categories"
        case .getFilteredFeedList:
            return "/feed/filtered"
        case .getFollowingFeedList:
            return "/feed/following"
        case .searchPost:
            return "/post/search"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getCategories, .getFilteredFeedList, .getFollowingFeedList, .searchPost:
            return .get
        case .reportPost, .reportUser:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getCategories, .getFollowingFeedList:
            return .requestPlain
        case .reportPost(let report):
            return .requestCustomJSONEncodable(report, encoder: JSONEncoder())
        case .reportUser(let report):
            return .requestCustomJSONEncodable(report, encoder: JSONEncoder())
        case .searchPost(let query):
            return .requestParameters(parameters: [
                "query": query
            ], encoding: URLEncoding.default)
        case .getFilteredFeedList(let request):
            var params: [String: Any] = [:]
            
            var category: [Int] = request.categoryIds
            
            if request.isLocal {
                category.insert(2, at: 0)
            }
            
            let joinedCategory = category.map { String($0) }.joined(separator: ",")
            params["categoryIds"] = joinedCategory

            if !request.regionIds.isEmpty {
                let joinedString = request.regionIds.map { String($0) }.joined(separator: ",")
                params["regionIds"] = joinedString
            }
            
            if !request.ageGroups.isEmpty {
                let joinedString = request.ageGroups.joined(separator: ",")
                params["ageGroups"] = joinedString
            }
            
            params["sortBy"] = request.sortBy
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }

    var headers: [String: String]? {
//        return HeaderType.auth.value
        return Config.defaultHeader
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
