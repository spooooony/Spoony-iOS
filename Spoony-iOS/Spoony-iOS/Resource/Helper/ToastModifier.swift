//
//  ToastModifier.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/10/25.
//

import Foundation
import SwiftUI

public struct Toast: Equatable {
    var style: ToastStyle
    var message: String
    var duration: Double = 3
    var width: Double = .infinity
    var yOffset: CGFloat = 638
}
