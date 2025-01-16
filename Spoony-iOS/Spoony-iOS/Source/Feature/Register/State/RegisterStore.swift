//
//  RegisterStore.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/16/25.
//

import Foundation

final class RegisterStore: ObservableObject {
    @Published var step: RegisterStep = .start
    @Published var text: String = ""
}
