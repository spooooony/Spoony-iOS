//
//  SplashView.swift
//  Spoony
//
//  Created by 최주리 on 9/30/25.
//

import SwiftUI

import ComposableArchitecture

struct SplashView: View {
    let store: StoreOf<SplashFeature>
    
    var body: some View {
        VStack {
            Color.main400
                .ignoresSafeArea()
                .overlay {
                    Image(.spoonyLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                }
                .onAppear {
                    store.send(.viewAction(.onAppear))
                }
        }
    }
}
