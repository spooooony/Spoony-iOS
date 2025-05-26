//
//  UploadImage.swift
//  Spoony-iOS
//
//  Created by 최안용 on 3/21/25.
//

import SwiftUI

struct UploadImage: Identifiable, Equatable {
    let id = UUID()
    let image: Image?
    let imageData: Data?
    var url: String? = nil
}
