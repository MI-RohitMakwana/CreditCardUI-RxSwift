//
//  Extension+Color.swift
//  CreditCardUI-RxSwift
//
//  Created by mind-0023 on 13/05/21.
//

import UIKit

extension UIColor {
    class var cardGradientTop: UIColor {
        return #colorLiteral(red: 0.3647058824, green: 0.5450980392, blue: 0.9490196078, alpha: 1)
    }

    class var cardGradientBottom: UIColor {
        return #colorLiteral(red: 0.2078431373, green: 0.2705882353, blue: 0.6823529412, alpha: 1)
    }
}

open class LineTextField: UITextField {
    
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
