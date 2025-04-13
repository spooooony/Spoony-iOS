//
//  UIPickerCoordinator.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/12/25.
//

import SwiftUI

final class UIPickerCoordinator: NSObject {
    var parent: CustomUIPickerView
    @Binding var selectedDate: [String]
    
    init(_ parent: CustomUIPickerView, _ selectedDate: Binding<[String]>) {
        self.parent = parent
        self._selectedDate = selectedDate
    }
}

extension UIPickerCoordinator: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        30
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        viewForRow row: Int,
        forComponent component: Int,
        reusing view: UIView?
    ) -> UIView {
        let text = parent.dataSource[component][row % parent.dataSource[component].count] + " " + DateType.allCases[component].title
        let font = UIFont.body2m
        
        let size = (text as NSString).size(withAttributes: [.font: font])
        
        let fixedHeight: CGFloat = 20.adjustedH
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = .spoonBlack
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: size.width, height: fixedHeight)
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: fixedHeight))
        container.addSubview(label)
        return container
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String? {
        return parent.dataSource[component][row % parent.dataSource[component].count]
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int
    ) {
        
        $selectedDate.wrappedValue[component] = parent.dataSource[component][row % parent.dataSource[component].count]
        
        if component != 2 {
            parent.updateDays(
                yearIndex: pickerView.selectedRow(inComponent: 0) % parent.dataSource[0].count,
                monthIndex: pickerView.selectedRow(inComponent: 1) % parent.dataSource[1].count
            )
            parent.$selectedDate.wrappedValue[2] = parent.dataSource[2][0]
            pickerView.reloadComponent(2)
            pickerView.selectRow(parent.dataSource[2].count * 5, inComponent: 2, animated: false)
        }
    }
}

extension UIPickerCoordinator: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return parent.dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return parent.dataSource[component].count * 10
    }
}
