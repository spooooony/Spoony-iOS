//
//  PlaceInfo.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/17/25.
//

import Foundation

struct PlaceInfo: Equatable, Identifiable {
    let id = UUID()
    let placeName: String
    let placeAddress: String
    let placeRoadAddress: String
    let latitude: Double
    let longitude: Double
}
