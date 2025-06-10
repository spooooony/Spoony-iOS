//
//  DatePickerBottomSheet.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/9/25.
//

import SwiftUI

struct DatePickerBottomSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedDate: [String]
    @State var pickerData: [String]
    
    init(isPresented: Binding<Bool>, selectedDate: Binding<[String]>) {
        self._isPresented = isPresented
        self._selectedDate = selectedDate
        pickerData = selectedDate.wrappedValue
    }
    
    var body: some View {
        VStack(spacing: 12) {
            headerView
            
            CustomUIPickerView(selectedDate: $pickerData)
                .frame(height: 144)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay {
                    VStack(spacing: 30.adjustedH) {
                        Rectangle()
                            .fill(.gray500)
                            .frame(height: 1.adjustedH)
                        Rectangle()
                            .fill(.gray500)
                            .frame(height: 1.adjustedH)
                    }
                }
            
            completeButton
        }
    }
}

extension DatePickerBottomSheet {
    private var headerView: some View {
        HStack {
            Spacer()
            Text("생년월일")
                .font(.body1b)
                .foregroundStyle(.gray900)
            Spacer()
        }
        .padding(.vertical, 16.5.adjustedH)
        .overlay {
            HStack {
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(.icCloseGray400)
                        .resizable()
                        .frame(width: 24.adjusted, height: 24.adjustedH)
                }
            }
            .padding(.trailing, 20.adjusted)
        }
    }
    
    private var completeButton: some View {
        Button {
            selectedDate = pickerData
            isPresented = false
        } label: {
            HStack {
                Spacer()
                Text("완료")
                    .font(.body1b)
                    .foregroundStyle(.white)
                Spacer()
            }
        }
        .padding(.vertical, 16.5.adjustedH)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(.spoonBlack)
        }
        .padding(.horizontal, 20.adjusted)
        .padding(.top, 12.adjustedH)
        .padding(.bottom, 28.adjustedH)
    }
}

struct CustomUIPickerView: UIViewRepresentable {
    typealias UIViewType = UIPickerView
    
    @Binding var selectedDate: [String]
    var dataSource: [[String]] = [[], [], []]
    
    init(selectedDate: Binding<[String]>) {
        self._selectedDate = selectedDate
        initialDateSource()
    }
    
    func makeUIView(context: Context) -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.delegate = context.coordinator
        pickerView.dataSource = context.coordinator
        
        for i in 0..<selectedDate.count {
            let value: String
            
            if selectedDate[i].isEmpty {
                if i == 0 {
                    let defaultYear = "2000"
                    value = defaultYear
                    guard let index = dataSource[i].firstIndex(of: defaultYear) else {
                        pickerView.selectRow(dataSource[i].count * 5, inComponent: i, animated: false)
                        continue
                    }
                    pickerView.selectRow(dataSource[i].count * 5 + index, inComponent: i, animated: false)
                } else {
                    value = dataSource[i][0]
                    pickerView.selectRow(dataSource[i].count * 5, inComponent: i, animated: false)
                }
            } else {
                value = selectedDate[i]
                guard let index = dataSource[i].firstIndex(of: value) else {
                    pickerView.selectRow(dataSource[i].count * 5, inComponent: i, animated: false)
                    continue
                }
                pickerView.selectRow(dataSource[i].count * 5 + index, inComponent: i, animated: false)
            }
            
            DispatchQueue.main.async {
                selectedDate[i] = value
            }
        }
        
        return pickerView
    }
    
    func updateUIView(_ uiView: UIPickerView, context: Context) {
        uiView.subviews.forEach {
            $0.backgroundColor = .clear
        }
    }
    
    func makeCoordinator() -> UIPickerCoordinator {
        UIPickerCoordinator(self, $selectedDate)
    }
}

extension CustomUIPickerView {
    mutating func updateMonth(yearIndex: Int) {
        let year = dataSource[0][yearIndex]
        
        dataSource[1] = DatePickerManager.shared.getMonths(year: year)
    }
    
    mutating func updateDays(yearIndex: Int, monthIndex: Int) {
        let year = dataSource[0][yearIndex]
        let month = dataSource[1][monthIndex]
                        
        dataSource[2] = DatePickerManager.shared.getDays(year: year, month: month)
    }
    
    mutating private func initialDateSource() {
        dataSource[0] = DatePickerManager.shared.getYears()
        if selectedDate[1].isEmpty {
            dataSource[1] = DatePickerManager.shared.getMonths(year: "2000")
        } else {
            dataSource[1] = DatePickerManager.shared.getMonths(year: selectedDate[0])
        }
        
        if selectedDate[2].isEmpty {
            dataSource[2] = DatePickerManager.shared.getDays(year: "2000", month: "01")
        } else {
            dataSource[2] = DatePickerManager.shared.getDays(year: selectedDate[0], month: selectedDate[1])
        }
    }
}

#Preview {
    DatePickerBottomSheet(isPresented: .constant(false), selectedDate: .constant(["", "", ""]))
}
