//
//  AgreeView.swift
//  Spoony-iOS
//
//  Created by 최주리 on 3/29/25.
//

import SwiftUI
import CoreLocation

import ComposableArchitecture

struct AgreeView: View {
    @Bindable private var store: StoreOf<AgreeFeature>
    
    @State private var locationManager = CLLocationManager()
    @StateObject private var locationDelegate = LocationManagerDelegate { _ in }
    
    init(store: StoreOf<AgreeFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text("전체 동의")
                    .customFont(.body1sb)
                    .foregroundColor(.gray900)
                Spacer()
                Image(store.state.allCheckboxFilled ? .icCheckboxfilledMain : .icCheckboxemptyGray400)
                    .onTapGesture {
                        store.send(.viewAction(.allAgreeTapped))
                    }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 16.5)
            .background(store.state.allCheckboxFilled ? .main0 : .gray0, in: RoundedRectangle(cornerRadius: 15))
            .padding(.top, 53)
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(AgreeType.allCases, id: \.self) { type in
                    AgreeSelectView(store: store, type: type)
                }
            }
            .padding(.top, 34)
            Spacer()
            SpoonyButton(
                style: .primary,
                size: .xlarge,
                title: "동의합니다",
                isIcon: false,
                disabled: $store.isDisableButton
            ) {
                switch locationManager.authorizationStatus {
                case .notDetermined:
                    locationManager.requestWhenInUseAuthorization()
                default:
                    store.send(.delegate(.routeToOnboardingScreen))
                }
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 20)
        .onAppear {
            locationManager.delegate = locationDelegate
        }
        .onChange(of: locationManager.authorizationStatus) {
            store.send(.delegate(.routeToOnboardingScreen))
        }
    }
}

struct AgreeSelectView: View {
    @Bindable private var store: StoreOf<AgreeFeature>
    private let agreeTypeModel: AgreeModel
    
    private var isSelected: Bool {
        return store.state.selectedAgrees.contains(agreeTypeModel.type)
    }
    
    init(
        store: StoreOf<AgreeFeature>,
        type: AgreeType
    ) {
        self.store = store
        self.agreeTypeModel = AgreeModel.typeToModel(from: type)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Group {
                if agreeTypeModel.hasURL {
                    Text(agreeTypeModel.title)
                        .underline()
                } else {
                    Text(agreeTypeModel.title)
                }
            }
            .customFont(.body2m)
            .foregroundStyle(.gray600)
            .onTapGesture {
                store.send(.viewAction(.agreeURLTapped(agreeTypeModel.type)))
            }
            Text(" (필수)")
                .customFont(.body2m)
                .foregroundStyle(.gray600)
            
            Spacer()
            
            Image(isSelected ? .icCheckboxfilledMain : .icCheckboxemptyGray400)
                .onTapGesture {
                    if isSelected {
                        store.send(.viewAction(.selectedAgreeTapped(agreeTypeModel.type)))
                    } else {
                        store.send(.viewAction(.unSelectedAgreeTapped(agreeTypeModel.type)))
                    }
                }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 3)
    }
    
}

#Preview {
    AgreeView(store: Store(initialState: AgreeFeature.State(), reducer: {
        AgreeFeature()
            ._printChanges()
    }))
}
