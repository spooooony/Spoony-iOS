//
//  AttendanceView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/13/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct AttendanceView: View {
    @Bindable private var store: StoreOf<AttendanceFeature>
    @State private var isInfoSheetPresented = false
    
    init(store: StoreOf<AttendanceFeature>) {
        self.store = store
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            backgroundView
            mainContentView
        }
        .sheet(isPresented: $isInfoSheetPresented) {
            AttendanceInfoSheetView()
                .presentationDetents([.medium])
        }
        .task {
            store.send(.onAppear)
        }
        .toolbar(store.showDailySpoonPopup ? .hidden : .visible, for: .tabBar)
        .overlay {
            if store.showDailySpoonPopup {
                SpoonDrawPopupView(
                    isPresented: Binding(
                        get: { store.showDailySpoonPopup },
                        set: { store.send(.setShowDailySpoonPopup($0)) }
                    ),
                    onDrawSpoon: {
                        store.send(.drawDailySpoon)
                    },
                    isDrawing: store.isDrawingSpoon,
                    drawnSpoon: store.drawnSpoon,
                    errorMessage: store.spoonDrawError
                )
            }
        }
    }
    
    private var backgroundView: some View {
        VStack {
            Spacer()
            Color.gray0
                .ignoresSafeArea()
                .frame(height: 168.adjustedH)
        }
        .background(.white)
        .ignoresSafeArea()
    }
    
    private var mainContentView: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                style: .attendanceCheck,
                title: "출석체크",
                spoonCount: store.spoonCount,
                onBackTapped: {
                    store.send(.routeToPreviousScreen)
                }
            )
            
            trackerContentView
                .padding(.horizontal, 20)
            
            if !store.hasDrawnSpoonToday {
                dailySpoonSection
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
            }
            
            noticeView
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
        }
    }
    
    private var trackerContentView: some View {
        VStack(alignment: .leading, spacing: 32) {
            headerView
            weekdayGridView
            Spacer().frame(height: 36)
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .lastTextBaseline) {
                Text("매일 출석하고\n오늘의 스푼을 획득하세요")
                    .font(.title1)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Image(.icInfoGray400)
                    .padding(.leading, 6)
                    .frame(width: 24, height: 24)
                    .onTapGesture {
                        isInfoSheetPresented = true
                    }
            }
            .padding(.top, 8)
            
            Text(store.dateRange)
                .font(.body2m)
                .foregroundColor(.gray400)
        }
    }
    
    private var dailySpoonSection: some View {
        VStack(spacing: 16) {
            Divider()
                .background(Color.gray100)
            
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("오늘의 스푼 받기")
                            .font(.title3b)
                            .foregroundColor(.spoonBlack)
                        
                        Text("아직 오늘 스푼을 받지 않았어요")
                            .font(.body2m)
                            .foregroundColor(.gray500)
                    }
                    
                    Spacer()
                    
                    SpoonyButton(
                        style: .secondary,
                        size: .xsmall,
                        title: "스푼 받기",
                        isIcon: false,
                        disabled: .constant(false)
                    ) {
                        store.send(.setShowDailySpoonPopup(true))
                    }
                }
            }
        }
    }
    
    private var weekdayGridView: some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        
        return LazyVGrid(columns: columns, spacing: 24) {
            ForEach(store.weekdays, id: \.self) { day in
                SpoonAttendanceView(
                    day: day,
                    isSelected: store.attendedWeekdays.keys.contains(day),
                    spoonDrawResponse: store.attendedWeekdays[day],
                    action: {
                        if !store.attendedWeekdays.keys.contains(day) {
                            if day != store.todayWeekday {
                                store.send(.drawSpoon(weekday: day))
                            } else {
                                store.send(.setShowDailySpoonPopup(true))
                            }
                        }
                    }
                )
            }
        }
        .padding(.vertical, 4)
    }
    
    private var noticeView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("유의사항")
                .font(.body2b)
                .foregroundColor(.gray400)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(store.noticeItems, id: \.self) { item in
                    BulletPointText(text: item)
                }
            }
        }
    }
}

struct BulletPointText: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.body2sb)
                .foregroundColor(.gray400)
            
            Text(text)
                .font(.body2sb)
                .foregroundColor(.gray400)
        }
    }
}

#Preview {
    AttendanceView(
        store: Store(initialState: AttendanceFeature.State.initialState) {
            AttendanceFeature()
        }
    )
}
