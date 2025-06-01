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
    case signup(SignupRequest, token: String)
    case logout
    case withdraw
    case refresh(token: String)
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
        case .logout:
            return "/auth/logout"
        case .withdraw:
            return "/auth/withdraw"
        case .refresh:
            return "/auth/refresh"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login, .signup, .logout, .withdraw, .refresh:
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
        case .signup(let request, _):
            return .requestCustomJSONEncodable(request, encoder: JSONEncoder())
        case .logout, .withdraw, .refresh:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .login(_, let token), .refresh(let token):
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(token)"
            ]
        case .signup(_, let token):
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(token)"
            ]
        case .logout, .withdraw:
            var headers = ["Content-Type": "application/json"]
            
            switch KeychainManager.read(key: .accessToken) {
            case .success(let token):
                if let token = token {
                    headers["Authorization"] = "Bearer \(token)"
                }
            case .failure(let error):
                print("Failed to read access token: \(error)")
            }
            
            return headers
        }
    }
}
