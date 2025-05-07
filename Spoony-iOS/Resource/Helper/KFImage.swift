//
//  KFImage.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/23/25.
//

import SwiftUI
import Kingfisher

struct RemoteImageView: View {
    let urlString: String
    
    var body: some View {
        KFImage(URL(string: urlString))
            .placeholder {
                Image(.default)
                    .resizable()
                    .scaledToFit()
            }
            .resizable()
            .fade(duration: 0.5)
            .cacheMemoryOnly()
    }
}
