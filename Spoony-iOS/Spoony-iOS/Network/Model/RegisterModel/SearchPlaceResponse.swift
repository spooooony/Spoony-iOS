//
//  SearchPlaceResponse.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/21/25.
//

import Foundation

struct SearchPlaceResponse: Codable {
    let placeList: [PlaceResponse]
}

struct PlaceResponse: Codable {
    let placeName: String
    let placeAddress: String
    let placeRoadAddress: String
    let latitude: Double
    let longitude: Double
}

extension SearchPlaceResponse {
    func toModel() -> [PlaceInfo] {
        return placeList.map {
            .init(
                placeName: $0.placeName,
                placeAddress: $0.placeAddress,
                placeRoadAddress: $0.placeRoadAddress,
                latitude: $0.latitude,
                longitude: $0.longitude
            )
        }
    }
}
