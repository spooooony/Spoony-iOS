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
            Spacer()
            Image(.spoonyLogo)
                .resizable()
                .frame(width: 105.adjusted, height: 151.adjustedH)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
        .background(.main400)
        .onAppear {
            store.send(.viewAction(.onAppear))
        }
    }
}
