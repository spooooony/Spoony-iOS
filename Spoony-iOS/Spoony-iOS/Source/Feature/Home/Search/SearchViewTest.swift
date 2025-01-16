//
//  SearchViewTest.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/16/25.
//

import SwiftUI

struct SearchViewTest: View {
   @State private var searchText = ""
   
   var body: some View {
       VStack(spacing: 0) {
           CustomNavigationBar(
               style: .searchBar,
               searchText: $searchText,
               onBackTapped: {},
               onSearchSubmit: {
                   print("Search submitted: \(searchText)")
               }
           )
           
           Spacer()
       }
   }
}

#Preview {
   SearchViewTest()
}
