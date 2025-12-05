//
//  NetworkResponse.swift
//  Spoony
//
//  Created by 최안용 on 10/4/25.
//

import Foundation

struct NetworkResponse {
  let statusCode: Int?
  let data: Data?
  let response: HTTPURLResponse?
}

extension NetworkResponse {
  func map<T: Decodable>(to type: T.Type) throws -> T {
    guard let data else {
        throw SNError.noData
    }
    
    do {
      return try JSONDecoder().decode(type, from: data)
    } catch let error as DecodingError {
      #if DEBUG
      print("🚨 [Decode] error:", error)
      if let jsonString = String(data: data, encoding: .utf8) {
        print("🚨 [Decode] raw json:", jsonString)
      }
      switch error {
      case .typeMismatch(let type, let context):
        print("🚨 [Decode] typeMismatch:", type, context.codingPath, context.debugDescription)
      case .valueNotFound(let type, let context):
        print("🚨 [Decode] valueNotFound:", type, context.codingPath, context.debugDescription)
      case .keyNotFound(let key, let context):
        print("🚨 [Decode] keyNotFound:", key, context.codingPath, context.debugDescription)
      case .dataCorrupted(let context):
        print("🚨 [Decode] dataCorrupted:", context.codingPath, context.debugDescription)
      @unknown default:
        print("🚨 [Decode] unknown error")
      }
      if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
        print("🚨 [Decode] top-level keys:", dict.keys)
      }
      #endif
        throw SNError.decodeError
    } catch {
      #if DEBUG
      print("🚨 [Decode] undefined error:", error)
      #endif
        throw SNError.etc
    }
  }
}
