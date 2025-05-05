//
//  ImageLoadServiceKey.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/5/25.
//

import Dependencies

enum ImageLoadServiceKey: DependencyKey {
    static let liveValue: ImageLoadServiceProtocol = ImageLoadService()
}
