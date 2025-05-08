//
//  ReviewCellIDKey.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 5/5/25.
//

import SwiftUI

struct ReviewCellIDKey: EnvironmentKey {
    static let defaultValue: String = ""
}

extension EnvironmentValues {
    var reviewCellID: String {
        get { self[ReviewCellIDKey.self] }
        set { self[ReviewCellIDKey.self] = newValue }
    }
}
