//
//  LocationPickerBottomSheet.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/15/25.
//

import SwiftUI

enum LocationType: String, CaseIterable {
    case seoul = "서울"
    case gyeonggi = "경기"
    case incheon = "인천"
    case gangwon = "강원"
    case busan = "부산"
    case daejeon = "대전"
    case daegu = "대구"
    case jeju = "제주"
    case ulsan = "울산"
    case gyeongnam = "경남"
    case gyeongbuk = "경북"
    case chungnam = "충남"
    case chungbuk = "충북"
    case sejong = "세종"
    case jeonnam = "전남"
    case jeonbuk = "전북"
    case gwangju = "광주"
}

// Region으로 바꾸기
enum SubLocationType: String, CaseIterable {
    case gangnam = "강남구"
    case gangdong = "강동구"
    case gangbuk = "강북구"
    case gangseo = "강서구"
    case gwanak = "관악구"
    case gwangjin = "광진구"
    case guro = "구로구"
    case geumcheon = "금천구"
    case nowon = "노원구"
    case dobong = "도봉구"
    case dongdaemun = "동대문구"
    case dongjak = "동작구"
    case mapo = "마포구"
    case seodaemun = "서대문구"
    case seocho = "서초구"
    case seongdong = "성동구"
    case seongbuk = "성북구"
    case songpa = "송파구"
    case yangcheon = "양천구"
    case yeongdeungpo = "영등포구"
    case yongsan = "용산구"
    case eunpyeong = "은평구"
    case jongno = "종로구"
    case jung = "중구"
    case jungnang = "중랑구"
}

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
