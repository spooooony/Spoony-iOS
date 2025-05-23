//
//  SpoonDrawTargetType.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 5/21/25.
//

import Foundation
import Moya

enum SpoonDrawTargetType {
    case getSpoonDrawInfo
    case drawSpoon
}

extension SpoonDrawTargetType: TargetType {
    var baseURL: URL {
        guard let url = URL(string: Config.baseURL) else {
            fatalError("baseURL could not be configured")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .getSpoonDrawInfo, .drawSpoon:
            return "/spoon/draw"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getSpoonDrawInfo:
            return .get
        case .drawSpoon:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getSpoonDrawInfo, .drawSpoon:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        return HeaderType.auth.value
    }
}
