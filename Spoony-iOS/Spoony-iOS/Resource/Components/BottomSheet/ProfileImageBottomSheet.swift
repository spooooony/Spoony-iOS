//
//  ProfileImageBottomSheet.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/16/25.
//

import SwiftUI
import Kingfisher

struct ProfileImageBottomSheet: View {
    @Binding var isPresented: Bool
    private let profileImages: [ProfileImage]
    
    init(isPresented: Binding<Bool>, profileImages: [ProfileImage]) {
        self._isPresented = isPresented
        self.profileImages = profileImages
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            imageListView
            Spacer()
        }
        .ignoresSafeArea()
    }
}

extension ProfileImageBottomSheet {
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(.icCloseWhite)
                        .resizable()
                        .frame(width: 24.adjusted, height: 24.adjustedH)
                }
            }
            .padding(.trailing, 20)
            .padding(.vertical, 4)
            
            Text("프로필 이미지")
                .font(.title2)
                .foregroundStyle(.white)
                .padding(.bottom, 12)
            
            Text("내 리뷰가 많이 저장될수록 프로필 이미지가 업그레이드 돼요.\n좋은 리뷰를 작성하고 다양한 스푼을 획득해 보세요!")
                .font(.body2m)
                .foregroundStyle(.gray400)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(
            GeometryReader { geo in
                Image(.bgBottomGrad)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
        )
    }
    
    private var imageListView: some View {
        VStack(spacing: 0) {
            ForEach(profileImages, id: \.self) { image in
                ProfileImageCell(image: image)
            }
        }
    }
}

private struct ProfileImageCell: View {
    @State private var isFail: Bool = false
    private let image: ProfileImage
    
    init(image: ProfileImage) {
        self.image = image
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 20) {
                if let url = URL(string: image.url) {
                    KFImage(url)
                        .placeholder({ _ in
                            Circle()
                                .fill(.gray200)
                        })
                        .onFailure({ _ in
                            isFail = true
                        })
                        .resizable()
                        .frame(width: 60.adjusted, height: 60.adjustedH)
                        .overlay {
                            if isFail {
                                Image(.icImageFail)
                                    .resizable()
                                    .frame(width: 18.adjusted, height: 18.adjustedH)
                            }
                        }
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(.gray200)
                        .frame(width: 60.adjusted, height: 60.adjustedH)
                        .overlay {
                            Image(.icImageFail)
                                .resizable()
                                .frame(width: 18.adjusted, height: 18.adjustedH)
                        }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("프로필 이미지_1 이름 (미정)")
                        .lineLimit(1)
                        .font(.body1sb)
                        .foregroundStyle(.spoonBlack)
                    
                    Text("\(image.unlockCondition)")
                        .lineLimit(1)
                        .font(.body2m)
                        .foregroundStyle(.gray600)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 9)
            .padding(.leading, 30)
            .padding(.trailing, 15)
            
            Rectangle()
                .fill(.gray100)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ProfileImageBottomSheet(isPresented: .constant(true), profileImages: [.init(url: "https://sojoong.joins.com/wp-content/uploads/sites/4/2024/12/01.jpg", imageLevel: 0, unlockCondition: "내 리뷰가 다른 유저들의 지도에 1000번 저장", isUnlocked: true)])
}
