//
//  Home.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI

struct Home: View {
    @State private var selectedPlace: Bool = true
    @State private var currentPage = 0
    @State private var searchText = ""
    
    let samplePlaces = [
        CardPlace(
            name: "파오리",
            visitorCount: "21",
            address: "서울특별시 마포구 와우산로",
            images: ["testImage1"],
            title: "클레오가트라",
            subTitle: "성동구 수제",
            description: "포켓몬 중 하나의 이름을 가졌지만 카페에요"
        ),
        CardPlace(
            name: "스타벅스",
            visitorCount: "45",
            address: "서울특별시 마포구 어울마당로",
            images: ["testImage1", "testImage2"],
            title: "클레오가트라",
            subTitle: "성동구 수제",
            description: "포켓몬 중 하나의 이름을 가졌지만 카페에요"
        ),
        CardPlace(
            name: "스타벅스",
            visitorCount: "45",
            address: "서울특별시 마포구 어울마당로",
            images: ["testImage1", "testImage2", "testImage3"],
            title: "클레오가트라",
            subTitle: "성동구 수제",
            description: "포켓몬 중 하나의 이름을 가졌지만 카페에요"
        )
    ]
    
    var body: some View {
<<<<<<< HEAD
        ZStack(alignment: .top) {
            NMapView()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                CustomNavigationBar(
                    style: .detail,
                    searchText: $searchText,
                    tappedAction: {
                        print("Navigation action tapped")
                    }
                )
                
                if selectedPlace {
                    ZStack {
                        VStack(spacing: 0) {
                            Spacer()
                            
                            PlaceCardsContainer(places: samplePlaces, currentPage: $currentPage)
                                .padding(.bottom, 4)
                            
                            PageIndicator(currentPage: currentPage, pageCount: samplePlaces.count)
                                .padding(.bottom, 4)
                        }
                    }
                }
            }
        }
    }
=======
           ZStack(alignment: .top) {
               NMapView()
                   .edgesIgnoringSafeArea(.all)
               
               VStack(spacing: 0) {
                   CustomNavigationBar(
                       style: .search(showBackButton: false),
                       searchText: $searchText,
                       onBackTapped: {},
                       onSearchSubmit: nil,
                       onLikeTapped: nil
                   )
                   
                   if selectedPlace {
                       ZStack { 
                           VStack(spacing: 0) {
                               Spacer()
                               
                               PlaceCardsContainer(places: samplePlaces, currentPage: $currentPage)
                                   .padding(.bottom, 4)
                               
                               PageIndicator(currentPage: currentPage, pageCount: samplePlaces.count)
                                   .padding(.bottom, 4)
                           }
                       }
                   }
               }
           }
       }
   }

#Preview {
    Home()
>>>>>>> parent of ab6cbd1 (Merge pull request #69 from SOPT-all/style/#66-fixDetailNavigation)
}

#Preview {
    Home()
        .environmentObject(NavigationManager())
}
