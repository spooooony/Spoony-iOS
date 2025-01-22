//
//  CardPlaceModel.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/15/25.
//

import Foundation

struct CardPlace: Identifiable {
    let id = UUID()
    let name: String
    let visitorCount: String
    let address: String
    let images: [String]
    let title: String
    let subTitle: String
    let description: String
    let categoryColor: String
    let categoryTextColor: String
}
