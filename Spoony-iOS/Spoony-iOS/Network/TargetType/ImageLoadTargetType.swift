//
//  ImageLoadTargetType.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/5/25.
//

import Foundation
import Moya

enum ImageLoadTargetType {
    case loadImage(url: String)
}

extension ImageLoadTargetType: TargetType {
    var baseURL: URL {
        switch self {
        case .loadImage(let url):
            guard let url = URL(string: url) else {
                fatalError("baseURL could not be configured")
            }
            return url
        }
    }
    
    var path: String {
        switch self {
        case .loadImage: ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .loadImage: return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .loadImage:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return Config.defaultHeader
    }
}
