//
//  Extension+TextField.swift
//  CreditCardUI-RxSwift
//
//  Created by mind-0023 on 17/05/21.
//

import UIKit

extension DateTextField {
    func datePicker<T>(target: T,
                       doneAction: Selector,
                       cancelAction: Selector,
                       minimumDate: Date? = nil,
                       dateType: DateType,
                       datePickerMode: UIDatePicker.Mode = .date) {

        inputView = nil
        inputAccessoryView = nil

        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))//1
        datePicker.datePickerMode = .date
        if let minDate = minimumDate {
            datePicker.minimumDate = minDate
        }

        if let date = self.selectedDate {
            datePicker.setDate(date, animated: true)
        }

        // iOS 13.4 and above
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.sizeToFit()
        }
        inputView = datePicker

        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: target, action: doneAction)
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: target, action: cancelAction)

        doneItem.accessibilityIdentifier = dateType.rawValue
        cancelItem.accessibilityIdentifier = dateType.rawValue

        toolBar.setItems([cancelItem, flexible, doneItem], animated: false)
        inputAccessoryView = toolBar
    }
}
