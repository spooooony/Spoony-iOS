//
//  DetailView.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI
import NMapsMap

struct DetailView: View {
    
    // MARK: - Properties
    
    private let userImage = Image(.icCafeBlue)
    private let userName: String = "럭키 백희"
    private let placeAdress: String = "서울시 마포구 수저"
    
    private var searchName = "연남"
    private var appName: String = "Spoony"
    @State private var isMyPost: Bool = true
    @State private var isPresented: Bool = false
    @State private var privateMode: Bool = false
    
    // MARK: - body
    
    var body: some View {
        
        CustomNavigationBar(style: .detailWithChip(count: 99), onBackTapped: {
            print("하이")
        })
        
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                userProfileSection
                imageSection
                reviewSection
                placeInfoSection
            }
        }
        .gesture(dragGesture)
        .onTapGesture {
            dismissDropDown()
        }
        .overlay(dropDownView, alignment: .topTrailing)
        
        bottomView
    }
}

// MARK: Gesture
extension DetailView {
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { _ in
                dismissDropDown()
            }
    }
}

// MARK: Method
extension DetailView {
    private func dismissDropDown() {
        isPresented = false
    }
}

// MARK: - Subviews

extension DetailView {
    private var userProfileSection: some View {
        HStack(alignment: .center, spacing: 14.adjustedH) {
            
            Image(.imgMockProfile)
                .resizable()
                .scaledToFit()
                .frame(width: 48.adjusted, height: 48.adjustedH)
            
            VStack(alignment: .leading, spacing: 4.adjustedH) {
                Text(userName)
                    .font(.body2b)
                    .foregroundStyle(.black)
                
                Text(placeAdress)
                    .font(.caption1b)
                    .foregroundStyle(.gray400)
            }
            
            Spacer()
            
            if isMyPost {
                Image(.icMenu)
                    .onTapGesture {
                        isPresented.toggle()
                    }
            }
            
        }
        .padding(EdgeInsets(top: 8.adjustedH, leading: 20.adjusted, bottom: 8.adjustedH, trailing: 20.adjusted))
        .padding(.bottom, 24.adjustedH)
    }
    
    private var imageSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(0..<4) { _ in
                    Image(.imgMockGodeung)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 278.adjusted)
                        .blur(radius: privateMode ? 12 : 0)
                        .cornerRadius(11.16)
                }
                .frame(height: 278.adjustedH)
            }
            .padding(EdgeInsets(top: 0, leading: 20.adjusted, bottom: 32.adjustedH, trailing: 20.adjusted))
        }
    }
    
    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 8.adjustedH) {
            IconChip(
                title: "주류",
                foodType: .bar,
                chipType: .small,
                color: .purple
            )
            
            Text("인생 이자카야. 고등어 초밥 안주가 그냥 미쳤어요.".splitZeroWidthSpace())
                .font(.title1b)
                .foregroundStyle(.black)
            
            Text("2025년 1월 2일")
                .font(.caption1m)
                .foregroundStyle(.gray400)
            
            Spacer().frame(height: 16.adjustedH)
            
            Text("이자카야인데 친구랑 가서 안주만 5개 넘게 시킴.. 명성이 자자한 고등어봉 초밥은 꼭 시키세요! 입에 넣자마자 사르르 녹아 없어짐. 그리고 밤 후식 진짜 맛도리니까 밤 디저트 좋아하는 사람이면 꼭 먹어보기! ")
                .font(.body2m)
                .foregroundStyle(.gray900)
            
        }
        .padding(.horizontal, 20.adjusted)
        .padding(.bottom, 32.adjustedH)
    }
    
    private var placeInfoSection: some View {
        VStack(spacing: 0) {
            menuInfo
                .background {
                    Rectangle()
                        .cornerRadius(20)
                        .foregroundStyle(.gray0)
                        .frame(maxHeight: .infinity)
                }
                .overlay(alignment: .bottom) {
                    Line()
                        .stroke(
                            style: StrokeStyle(
                                lineWidth: 1.adjustedH,
                                dash: [8.adjusted]
                            )
                        )
                        .foregroundStyle(.gray200)
                        .frame(width: 266.adjusted, height: 1.adjustedH, alignment: .bottom)
                }
            
            locationInfo
                .background {
                    Rectangle()
                        .frame(maxHeight: 134.adjustedH)
                        .cornerRadius(20)
                        .foregroundStyle(.gray0)
                }
            
        }
        .padding(.horizontal, 20.adjusted)
        .blur(radius: privateMode ? 8 : 0)
    }
    
    private var menuInfo: some View {
        VStack(alignment: .leading, spacing: 12.adjustedH) {
            Text("Menu")
                .font(.body1b)
                .foregroundStyle(.spoonBlack)
            menuList()
        }
        .padding(EdgeInsets(top: 20.adjustedH, leading: 16.adjusted, bottom: 28.adjustedH, trailing: 20.adjusted))
    }
    
    private var locationInfo: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12.adjustedH) {
                Text("Location")
                    .font(.body1b)
                    .foregroundStyle(.spoonBlack)
                Text("상호명")
                    .font(.title2sb)
                    .foregroundStyle(.spoonBlack)
                HStack(spacing: 4.adjusted) {
                    Image(.icMapGray400)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20.adjusted, height: 20.adjustedH)
                    
                    Text("서울 마포구 연희로11가길 39")
                        .font(.body2m)
                        .foregroundStyle(.spoonBlack)
                }
            }
            
            Spacer()
        }
        .padding(EdgeInsets(top: 21.adjustedH, leading: 16.adjusted, bottom: 25.adjustedH, trailing: 20.adjusted))
    }
    
    private var bottomView: some View {
        HStack(spacing: 0) {
            SpoonyButton(
                style: .secondary,
                size: privateMode ? .xlarge : .medium,
                title: privateMode ? "떠먹기" : "길찾기",
                isIcon: privateMode ? true : false,
                disabled: .constant(false)
            ) {
                
                if privateMode {
                    // TODO: 모달창 기능 구현 하기
                } else {
                    let url = URL(string: "nmap://search?query=\(searchName)&appname=\(appName)")!
                    let appStoreURL = URL(string: "http://itunes.apple.com/app/id311867728?mt=8")!
                    
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.open(appStoreURL)
                    }
                }
            }
            
            if !privateMode {
                Spacer()
                
                VStack(spacing: 4) {
                    Image(.icAddmapGray400)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 56.adjusted, height: 32.adjustedH)
                    
                    Text("99")
                        .font(.caption1m)
                        .foregroundStyle(.gray800)
                }
            }
        }
        .padding(.horizontal, 20.adjusted)
    }
    
    private var dropDownView: some View {
        Group {
            if isPresented {
                DropDownMenu(
                    items: ["신고하기"],
                    isPresented: $isPresented
                ) { menu in
                    print("선택된 메뉴: \(menu)")
                    isPresented = false
                }
                .frame(alignment: .topTrailing)
                .padding(.top, 48.adjustedH)
                .padding(.trailing, 20.adjusted)
            }
        }
    }
}

struct menuList: View {
    var menus: [String] = ["고등어봉초밥", "고등어봉초밥", "고등어봉초밥"]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<menus.count, id: \.self) { index in
                HStack(spacing: 4) {
                    Image(.icSpoonGray600)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20.adjusted, height: 20.adjustedH)
                    Text(menus[index])
                        .font(.body2m)
                        .lineLimit(2)
                    Spacer()
                }
            }
        }
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

#Preview {
    DetailView()
}
