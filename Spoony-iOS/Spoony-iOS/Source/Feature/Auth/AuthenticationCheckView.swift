////
////  AuthenticationCheckView.swift
////  Spoony-iOS
////
////  Created by 최주리 on 3/25/25.
////
//
//import SwiftUI
//
//import ComposableArchitecture
//
//struct AuthenticationCheckView: View {
//    //    @EnvironmentObject private var authNavigationManager: AuthNavigationManager
//    private let authenticationManager = AuthenticationManager.shared
//    @StateObject private var authNavigationManager: AuthNavigationManager = AuthNavigationManager()
//    
//    var body: some View {
//        VStack {
//            switch authenticationManager.authenticationState {
//            case .authenticated:
//                //                SpoonyTabView()
//                //                    .environmentObject(navigationManager)
//                EmptyView()
//            case .unAuthenticated:
//                NavigationStack(path: $authNavigationManager.path) {
//                    LoginView(
//                        store: StoreOf<LoginFeature>(
//                            initialState: LoginFeature.State(),
//                            reducer: {
//                                LoginFeature(navigationManager: authNavigationManager)
//                            }))
//                    .navigationDestination(for: AuthViewType.self) { view in
//                        authNavigationManager.build(view)
//                            .navigationBarBackButtonHidden()
//                    }
//                    .environmentObject(authNavigationManager)
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    AuthenticationCheckView()
//}
