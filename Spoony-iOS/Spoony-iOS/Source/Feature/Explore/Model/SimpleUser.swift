//
//  SimpleUser.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/6/25.
//

import Foundation

struct SimpleUser: Identifiable, Hashable {
    let id: Int
    let userName: String
    let regionName: String
    let profileImage: String
}
