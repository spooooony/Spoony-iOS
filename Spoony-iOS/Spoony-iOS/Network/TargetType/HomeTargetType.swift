//
//  HomeTargetType.swift
//  SpoonMe
//
//  Created by 이명진 on 1/20/25.
//

import Foundation
import Moya

enum HomeTargetType {
    case getSpoonCount
    case getMapList
    case getMapFocus(placeId: Int)
    case getSearchResultList(query: String)
    case getSearchResultLocation(locationId: Int)
    case getLocationList(locationId: Int)
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
        case .getSpoonCount:
            return "/spoon"
        case .getMapList:
            return "/post/zzim"
        case .getMapFocus(let placeId):
            return "/post/zzim/\(placeId)"
        case .getSearchResultList:
            return "/location/search"
        case .getSearchResultLocation(let locationId):
            return "/post/zzim/location/\(locationId)"
        case .getLocationList(let locationId):
            return "/post/zzim/location/\(locationId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getSpoonCount,
                .getMapList,
                .getMapFocus,
                .getSearchResultList,
                .getLocationList,
                .getSearchResultLocation:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getSpoonCount,
                .getMapList,
                .getMapFocus,
                .getLocationList,
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
