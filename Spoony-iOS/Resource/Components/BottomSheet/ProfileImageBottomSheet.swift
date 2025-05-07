//
//  ProfileImageBottomSheet.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/16/25.
//

import SwiftUI

struct ProfileImageBottomSheet: View {
    @Binding var isPresented: Bool
    
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
            // TODO: - 나중에 정해지면 다시
            ForEach(0..<6, id: \.self) { _ in
                imageCell
            }
        }
    }
    
    private var imageCell: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {                
                // TODO: - 나중에 이미지로 대체
                Circle()
                    .fill(.gray200)
                    .frame(width: 60.adjusted, height: 60.adjustedH)
                    .clipped()
                    .padding(.leading, 22)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("프로필 이미지_1 이름 (미정)")
                        .lineLimit(1)
                        .font(.body1sb)
                        .foregroundStyle(.spoonBlack)
                    
                    Text("기본 스푼. 스푸니에 오신 걸 환영해요!")
                        .lineLimit(1)
                        .font(.body2m)
                        .foregroundStyle(.gray600)
                }
                Spacer()
            }
            .padding([.horizontal, .top], 10)
            .padding(.bottom, 9)
            
            Rectangle()
                .fill(.gray100)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
        }        
    }
}

#Preview {
    ProfileImageBottomSheet(isPresented: .constant(true))
}
