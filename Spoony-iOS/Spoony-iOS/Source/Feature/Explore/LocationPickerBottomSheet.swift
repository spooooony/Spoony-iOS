//
//  LocationPickerBottomSheet.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/15/25.
//

import SwiftUI

enum RegionType: String, CaseIterable {
    case seoul = "서울"
    case gyeonggi = "경기"
    case busan = "부산"
    case daegu = "대구"
    case incheon = "인천"
    case gwangju = "광주"
    case daejeon = "대전"
    case ulsan = "울산"
    case sejong = "세종"
}

enum SeoulType: String, CaseIterable {
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
    @ObservedObject var store: ExploreStore
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("지역 선택")
                    .customFont(.body1b)
                
                HStack {
                    Spacer()
                    
                    Image(.icCloseGray400)
                        .onTapGesture {
                            store.dispatch(.closeLocationTapped)
                        }
                }
                .padding(.trailing, 20)
            }
            .frame(height: 32.adjustedH)
            .padding(.vertical, 12)
            
            HStack(alignment: .top, spacing: 0) {
                VStack(spacing: 0) {
                    ForEach(RegionType.allCases, id: \.self) { region in
                        Text(region.rawValue)
                            .customFont(.body2m)
                            .foregroundStyle(
                                region.rawValue == "서울" ? .spoonBlack : .gray400
                            )
                            .frame(width: 135.adjusted, height: 44.adjustedH)
                            .background(
                                region.rawValue == "서울" ? .clear : .gray0
                            )
                            .overlay(
                                Rectangle()
                                    .stroke(.gray0)
                            )
                    }
                }
                
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(SeoulType.allCases, id: \.self) { type in
                            
                            Text(type.rawValue)
                                .customFont(.body2m)
                                .foregroundStyle(
                                    store.state.tempLocation?.rawValue != type.rawValue ? .gray400 : .spoonBlack
                                )
                                .frame(width: 240.adjusted, height: 44.adjustedH)
                                .background(
                                    Rectangle()
                                        .stroke(Color.gray0, lineWidth: 1)
                                )
                                .onTapGesture {
                                    store.dispatch(.locationTapped(type))
                                }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                
            }
            
            SpoonyButton(
                style: .secondary,
                size: .xlarge,
                title: "선택하기",
                disabled: Binding(get: {
                    store.state.isSelectLocationButtonDisabled
                }, set: { newValue in
                    store.dispatch(.isSelectLocationDisabledChanged(newValue))
                })
            ) {
                store.dispatch(.selectLocationTapped)
            }
            .padding(.top, 12)
            .padding(.bottom, 22)
        }
    }
}
