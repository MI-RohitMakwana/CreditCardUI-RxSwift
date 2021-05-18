//
//  LineTextField.swift
//  CreditCardUI-RxSwift
//
//  Created by mind-0023 on 17/05/21.
//

import UIKit

class LineTextField: UITextField {

    private var lineView = UIView(frame: .zero)
    var lineBackgroundColor : UIColor = .lightGray {
        didSet {
            self.lineView.backgroundColor = lineBackgroundColor
        }
    }

    func setup() {
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = .darkGray
        self.addSubview(lineView)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [self.lineView.heightAnchor.constraint(equalToConstant: 1),
             self.lineView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
             self.lineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
             self.lineView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)]
        )
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}


class DateTextField: LineTextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var selectedDate: Date? {
        didSet{
            if let date = selectedDate{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/yy"
                let dateString = dateFormatter.string(from: date)
                text = dateString
            }
        }
    }
}
