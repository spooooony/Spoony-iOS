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
    case registerPost(request: RegisterPostRequest, imagesDate: [Data])
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
    
    var task: Moya.Task {
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
        case let .registerPost(request, imagesData):
            guard let multipartData = createMultipartData(from: request, images: imagesData) else {
                fatalError("Multipart data could not be created")
            }
            
            return .uploadMultipart(multipartData)
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .searchPlace, .getRegisterCategories, .validatePlace:
            return Config.defaultHeader
        case .registerPost:
            return [
                "Content-Type": "multipart/form-data",
                "Authorization": "Bearer \(Config.fixedAccessToken)"
            ]
        }
    }
}

extension RegisterTargetType {
    private func createMultipartData(from request: RegisterPostRequest, images: [Data]) -> [MultipartFormData]? {
        var formData: [MultipartFormData] = []
        
        guard let jsonObject = try? JSONEncoder().encode(request),
              let jsonDict = try? JSONSerialization.jsonObject(with: jsonObject),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: []) else {
            print("Failed to serialize RegisterPostRequest to JSON string")
            return nil
        }
        
        formData.append(MultipartFormData(
            provider: .data(jsonData),
            name: "data",
            mimeType: "application/json"
        ))
        
        for (index, imageData) in images.enumerated() {
            let fileName = "image\(index + 1).jpeg"
            let mimeType = "image/jpeg"
            
            formData.append(MultipartFormData(
                provider: .data(imageData),
                name: "photos",
                fileName: fileName,
                mimeType: mimeType
            ))
        }
        
        return formData
    }
}
