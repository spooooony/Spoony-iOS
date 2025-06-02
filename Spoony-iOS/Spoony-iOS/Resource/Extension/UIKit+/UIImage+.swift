//
//  UIImage+.swift
//  Spoony-iOS
//
//  Created by 최안용 on 6/2/25.
//

import UIKit

extension UIImage {
    public func downscaleTOjpegData(maxBytes: UInt) -> Data? {
        var quality = 1.0
        while quality > 0 {
            guard let jpeg = jpegData(compressionQuality: quality)
            else { return nil }
            if jpeg.count <= maxBytes {
                return jpeg
            }
            quality -= 0.1
        }
        return nil
    }
}
