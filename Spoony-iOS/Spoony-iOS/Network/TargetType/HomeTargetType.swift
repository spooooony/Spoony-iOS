//
//  HomeTargetType.swift
//  SpoonMe
//
//  Created by 이명진 on 1/20/25.
//

import Foundation
import Moya

enum HomeTargetType {
    case getSpoonCount(userId: Int)
    case getMapList(userId: Int)
    case getMapFocus(userId: Int, placeId: Int)
    case getSearchResultList(query: String)
    case getSearchResultLocation(userId: Int, locationId: Int)
}

extension HomeTargetType: TargetType {
    
    var baseURL: URL {
        guard let url = URL(string: Config.baseURL) else {
            fatalError("baseURL could not be configured")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .getSpoonCount(let userId):
            return "/spoon/\(userId)"
        case .getMapList(let userId):
            return "/post/zzim/\(userId)"
        case .getMapFocus(let userId, let placeId):
            return "/post/zzim/\(userId)/\(placeId)"
        case .getSearchResultList:
            return "/location/search"
        case .getSearchResultLocation(let userId, let locationId):
            return "/post/zzin/\(userId)/\(locationId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getSpoonCount,
                .getMapList,
                .getMapFocus,
                .getSearchResultList,
                .getSearchResultLocation:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getSpoonCount,
                .getMapList,
                .getMapFocus,
                .getSearchResultLocation:
            return .requestPlain
            
        case .getSearchResultList(let query):
            return .requestParameters(
                parameters: ["query": query],
                encoding: URLEncoding.default
            )
        }
    }
    
    var headers: [String: String]? {
        return Config.defaultHeader
    }
}
