//
//  LocationPickerBottomSheet.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/15/25.
//

import SwiftUI

// TODO: 서버 드리븐으로 바꾸기
enum LocationType: String, CaseIterable {
    case seoul = "서울"
    case gyeonggi = "경기"
    case busan = "부산"
    case daegu = "대구"
    case incheon = "인천"
    case gwangju = "광주"
    case daejeon = "대전"
    case ulsan = "울산"
    case sejong = "세종"
    case jeonbuk = "전북"
    case jeonnam = "전남"
}

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
    @Binding var isPresented: Bool
    @Binding var selectedLocation: LocationType
    @Binding var selectedSubLocation: SubLocationType?
    
    @State private var isDisable: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            titleView
            
            HStack(alignment: .top, spacing: 0) {
                locationView
                
                if selectedLocation == .seoul {
                    subLocationView
                } else {
                    emptyView
                }
            }
            
            SpoonyButton(
                style: .secondary,
                size: .xlarge,
                title: "선택하기",
                disabled: $isDisable
            ){
                isPresented = false
            }
            .padding(.top, 12)
            .padding(.bottom, 22)
        }
        .onChange(of: selectedSubLocation) { _, newValue in
            if newValue != nil {
                isDisable = false
            }
        }
        // TODO: 유즈케이스 맞춰서 수정하기
        .onChange(of: selectedLocation) { _, _ in
            isDisable = true
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
                        
                    }
            }
            .padding(.trailing, 20)
        }
        .frame(height: 32.adjustedH)
        .padding(.vertical, 12)
    }
    
    private var locationView: some View {
        VStack(spacing: 0) {
            ForEach(LocationType.allCases, id: \.self) { location in
                Text(location.rawValue)
                    .customFont(.body2m)
                    .foregroundStyle(selectedLocation == location ? .spoonBlack : .gray400)
                    .frame(width: 135.adjusted, height: 44.adjustedH)
                    .background(selectedLocation == location ? .clear : .gray0)
                    .overlay(
                        Rectangle()
                            .stroke(.gray0)
                    )
                    .onTapGesture {
                        selectedLocation = location
                    }
            }
        }
    }
    
    private var subLocationView: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(SubLocationType.allCases, id: \.self) { type in
                    
                    Text(type.rawValue)
                        .customFont(.body2m)
                        .foregroundStyle(selectedSubLocation == type ? .spoonBlack : .gray400)
                        .frame(width: 240.adjusted, height: 44.adjustedH)
                        .background(
                            Rectangle()
                                .stroke(Color.gray0, lineWidth: 1)
                        )
                        .onTapGesture {
                            selectedSubLocation = type
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

#Preview {
    LocationPickerBottomSheet(isPresented: .constant(true), selectedLocation: .constant(.gwangju), selectedSubLocation: .constant(nil))
}
