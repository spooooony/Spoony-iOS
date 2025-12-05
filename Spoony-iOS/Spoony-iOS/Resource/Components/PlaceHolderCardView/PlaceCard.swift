//
//  PlaceCard.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/15/25.
//

import SwiftUI
import ComposableArchitecture

struct PlaceCard: View {
    let store: StoreOf<MapFeature>
    let places: [CardPlace]
    @Binding var currentPage: Int
    let onCardTapped: ((CardPlace) -> Void)?
    
    init(store: StoreOf<MapFeature>, places: [CardPlace], currentPage: Binding<Int>) {
        self.store = store
        self.places = places
        self._currentPage = currentPage
        self.onCardTapped = nil
    }
    
    init(store: StoreOf<MapFeature>, places: [CardPlace], currentPage: Binding<Int>, onCardTapped: @escaping (CardPlace) -> Void) {
        self.store = store
        self.places = places
        self._currentPage = currentPage
        self.onCardTapped = onCardTapped
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(self.places.indices, id: \.self) { index in
                    PlaceCardItem(place: places[index])
                        .tag(index)
                        .padding(.horizontal, 26)
                        .onTapGesture {
                            let place = places[index]
                            if let callback = onCardTapped {
                                callback(place)
                            } else {
                                store.send(.delegate(.routeToPostView(postId: place.postId)))
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 264.adjusted)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .background(.clear)
            
            if places.count > 1 {
                PageIndicator(
                    currentPage: currentPage,
                    pageCount: places.count
                )
                .padding(.vertical, 4)
            }
        }
    }
}

private struct PlaceCardItem: View {
    let place: CardPlace
    
    var body: some View {
        VStack(spacing: 0) {
            Image(.imagecontainerViewTriangle)
                .resizable()
                .frame(width: 16.adjusted, height: 14.adjustedH)
                .zIndex(1)
                .background(Color.clear)
            
            VStack(spacing: 0) {
                PlaceImagesLayout(images: place.images)
                
                PlaceHeaderSection(place: place)
                    .padding(15)
                
                PlaceInfoSection(place: place)
                    .padding(15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.gray0)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 15)
                    .padding(.bottom, 15)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .background(Color.clear)
    }
}

private struct PlaceHeaderSection: View {
    let place: CardPlace
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 6) {
                Text(place.name)
                    .customFont(.body1b)
                    .lineLimit(1)
                
                CategoryLabel(place: place)
                
                Spacer()
                
                VisitorCountLabel(count: place.visitorCount)
            }
        }
    }
}

private struct CategoryLabel: View {
    let place: CardPlace
    
    var body: some View {
        HStack(spacing: 4) {
            AsyncImage(url: URL(string: place.categoryIcon)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16.adjusted, height: 16.adjustedH)
            } placeholder: {
                Rectangle().redacted(reason: .placeholder)
            }
            
            Text(place.description)
                .customFont(.caption1m)
        }
        .foregroundColor(Color(hex: place.categoryTextColor))
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color(hex: place.categoryColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct VisitorCountLabel: View {
    let count: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(.icAddmapGray400)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16.adjusted, height: 16.adjustedH)
            Text(count)
                .customFont(.caption2b)
                .foregroundStyle(.gray500)
        }
    }
}

private struct PlaceInfoSection: View {
    let place: CardPlace
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(place.title)
                    .customFont(.body2sb)
                    .lineLimit(1)
                    .foregroundStyle(.gray900)
                Text("서울 \(place.address) 스푼")
                    .customFont(.caption1m)
                    .foregroundColor(.gray600)
            }
            Text(place.subTitle)
                .customFont(.caption1m)
                .foregroundColor(.spoonBlack)
        }
    }
}
