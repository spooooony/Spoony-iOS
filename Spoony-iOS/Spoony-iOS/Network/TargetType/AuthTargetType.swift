//
//  AuthTargetType.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/22/25.
//

import Foundation
import Moya

enum AuthTargetType {
    case login(platform: String, token: String)
    // TODO: authorization에 뭐들어가야됨.. 전윤혁이랑 상의 후 마무리 하기
    case signup(SignupRequest)
}

extension AuthTargetType: TargetType {
    var baseURL: URL {
        guard let url = URL(string: Config.baseURL) else {
            fatalError("baseURL could not be configured")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .signup:
            return "/auth/signup"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login, .signup:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .login(let platform, _):
            return .requestParameters(
                parameters: ["platform": platform],
                encoding: JSONEncoding.default
            )
        case .signup(let request):
            return .requestCustomJSONEncodable(request, encoder: JSONEncoder())
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .login(_, let token):
            HeaderType.token(token).value
        case .signup:
            HeaderType.auth.value
        }
    }
}
