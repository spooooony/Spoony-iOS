//
//  SplashView.swift
//  Spoony
//
//  Created by 최주리 on 9/30/25.
//

import SwiftUI

import ComposableArchitecture

struct SplashView: View {
    private var store: StoreOf<SplashFeature>
    
    var body: some View {
        VStack {
            Spacer()
            Image(.spoonyLogo)
            Spacer()
        }
        .ignoresSafeArea()
        .onAppear {
            store.send(.onAppear)
        }
    }
}
