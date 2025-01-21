//
//  RegisterTargetType.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/20/25.
//

import Foundation
import Moya

enum RegisterTargetType {
    case searchPlace(query: String)
    case validatePlace(request: ValidatePlaceRequest)
    case registerPost
    case getRegisterCategories
}

extension RegisterTargetType: TargetType {
    
    var baseURL: URL {
        guard let url = URL(string: Config.baseURL) else {
            fatalError("baseURL could not be configured")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .searchPlace:
            return "/place/search"
        case .validatePlace:
            return "/place/check"
        case .registerPost:
            return "/post"
        case .getRegisterCategories:
            return "/post/categories/food"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .searchPlace, .getRegisterCategories:
            return .get
        case .validatePlace, .registerPost:
            return .post
        }
    }
    
    var task: Moya.Task { // TODO: 멀티파트 통신 해야합니다!!
        switch self {
        case .searchPlace(let query):
            return .requestParameters(
                parameters: ["query": query],
                encoding: URLEncoding.queryString
            )
        case .getRegisterCategories:
            return .requestPlain
        case .validatePlace(let request):
            return .requestJSONEncodable(request)
        case .registerPost:
            return .uploadMultipart([])
        }
    }
    
    var headers: [String: String]? {
        return Config.defaultHeader
    }
}
