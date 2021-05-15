//
//  Extensuin+UIView.swift
//  CreditCardUI-RxSwift
//
//  Created by mind-0023 on 13/05/21.
//

import UIKit

extension UIView {
    func loadViewFromNib() {
        let nibName = NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
        guard let view = Bundle(for: type(of: self)).loadNibNamed(nibName, owner: self, options: nil)?.first as? UIView else { return }
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        let views = ["view": view]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: views))
        setNeedsUpdateConstraints()
    }

    func applyGradient(WithColors colors: [CGColor]) {
        let gradient = CAGradientLayer()
        gradient.colors = colors
        gradient.locations = [0.0,1.0]
        gradient.frame = self.bounds
        self.layer.insertSublayer(gradient, at: 0)
    }
}
