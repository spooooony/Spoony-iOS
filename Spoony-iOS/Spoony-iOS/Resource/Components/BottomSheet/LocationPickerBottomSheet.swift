//
//  LocationPickerBottomSheet.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/15/25.
//

import SwiftUI

struct LocationPickerBottomSheet: View {
    @Binding private var isPresented: Bool
    @Binding private var selectedLocation: LocationType
    @Binding private var selectedSubLocation: Region?
    
    @State private var tempLocation: LocationType = .seoul
    @State private var tempSubLocation: Region?
    
    @State private var isDisabled: Bool = true
    
    private let regionList: [Region]
    
    init(
        isPresented: Binding<Bool>,
        selectedLocation: Binding<LocationType>,
        selectedSubLocation: Binding<Region?>,
        regionList: [Region]
    ) {
        self._isPresented = isPresented
        self._selectedLocation = selectedLocation
        self._selectedSubLocation = selectedSubLocation
        self.regionList = regionList
    }
    
    var body: some View {
        VStack(spacing: 0) {
            titleView
            
            HStack(alignment: .top, spacing: 0) {
                locationView
                
                if tempLocation == .seoul {
                    subLocationView
                } else {
                    emptyView
                }
            }
            
            SpoonyButton(
                style: .secondary,
                size: .xlarge,
                title: "선택하기",
                disabled: $isDisabled
            ) {
                selectedLocation = tempLocation
                selectedSubLocation = tempSubLocation
                isPresented = false
            }
            .padding(.top, 12)
            .padding(.bottom, 22)
        }
        .onChange(of: tempSubLocation) { _, newValue in
            if newValue != nil {
                isDisabled = false
            }
        }
        .onChange(of: tempLocation) { _, _ in
            tempSubLocation = nil
            isDisabled = true
        }
    }
}

extension LocationPickerBottomSheet {
    private var titleView: some View {
        ZStack {
            Text("지역 선택")
                .customFont(.body1b)
            
            HStack {
                Spacer()
                
                Image(.icCloseGray400)
                    .onTapGesture {
                        isPresented = false
                    }
            }
            .padding(.trailing, 20)
        }
        .frame(height: 32.adjustedH)
        .padding(.vertical, 12)
    }
    
    private var locationView: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(LocationType.allCases, id: \.self) { location in
                    Text(location.rawValue)
                        .customFont(.body2m)
                        .foregroundStyle(tempLocation == location ? .spoonBlack : .gray400)
                        .frame(width: 135.adjusted, height: 44.adjustedH)
                        .background(tempLocation == location ? .clear : .gray0)
                        .overlay(
                            Rectangle()
                                .stroke(.gray0)
                        )
                        .onTapGesture {
                            tempLocation = location
                        }
                }
            }
        }
        .scrollIndicators(.hidden)
    }
    
    private var subLocationView: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(regionList, id: \.id) { region in
                    
                    Text(region.regionName)
                        .customFont(.body2m)
                        .foregroundStyle(tempSubLocation == region ? .spoonBlack : .gray400)
                        .frame(width: 240.adjusted, height: 44.adjustedH)
                        .background(
                            Rectangle()
                                .stroke(Color.gray0, lineWidth: 1)
                        )
                        .onTapGesture {
                            tempSubLocation = region
                        }
                }
            }
        }
        .scrollIndicators(.hidden)
    }
    
    private var emptyView: some View {
        VStack {
            Spacer()
            Text("지금은 서울만 가능해요!\n다른 지역은 열심히 준비 중이에요.")
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .customFont(.body2m)
                .foregroundStyle(.gray400)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
