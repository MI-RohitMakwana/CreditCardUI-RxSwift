//
//  CreditCardView.swift
//  CreditCardUI-RxSwift
//
//  Created by mind-0023 on 13/05/21.
//

import UIKit
import RxCocoa
import RxSwift

protocol CreditCardViewProtocol {
    func onCardHolderNameChanged(_ text: String)
    func onCardNumberChanged(_ text: String)
    func onValidFromDateChanged(_ text: String)
    func onValidThruDateChanged(_ text: String)
    func onCVVNumberChanged(_ text: String)
}

final class CreditCardView: UIView {

    // MARK: - IBOutlets
    @IBOutlet fileprivate weak var frontView: UIView!
    @IBOutlet fileprivate weak var backView: UIView!
    @IBOutlet fileprivate weak var cardHolderNameLabel: UILabel!
    @IBOutlet fileprivate weak var cardNumberLabel: UILabel!
    @IBOutlet fileprivate weak var validFromDateLabel: UILabel!
    @IBOutlet fileprivate weak var validThruDateLabel: UILabel!
    @IBOutlet fileprivate weak var cvvNumberLabel: UILabel!

    // MARK: - Declared Variables
    fileprivate var cardHolderName = BehaviorRelay<String?>(value: "")
    fileprivate var cardNumber = BehaviorRelay<String?>(value: "")
    fileprivate var validFromDate = BehaviorRelay<String?>(value: "")
    fileprivate var validThruDate = BehaviorRelay<String?>(value: "")
    fileprivate var cvvNumber = BehaviorRelay<String?>(value: "")
    fileprivate var showingBack:Bool = false
    fileprivate let disposeBag = DisposeBag()

    private struct CardDefaultValues {
        static let cardHolderName = "CARD HOLDER"
        static let cardNumber = "XXXX XXXX XXXX XXXX"
        static let validFromDate = "MM/YY"
        static let validThruDate = "MM/YY"
        static let cvvNumber = "***"
    }

    // MARK: - Init Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.xibSetup()
    }

    // MARK: - XIB SetUp
    fileprivate func xibSetup() {
        self.loadViewFromNib()
        self.frontView.applyGradient(
            WithColors: [UIColor.cardGradientTop.cgColor,
                         UIColor.cardGradientBottom.cgColor]
        )
        self.backView.applyGradient(
            WithColors: [UIColor.cardGradientTop.cgColor,
                         UIColor.cardGradientBottom.cgColor]
        )
        self.bindLabels()
    }

    // Bind labels
    private func bindLabels() {

        self.cardHolderName.bind(to: self.cardHolderNameLabel.rx.text)
            .disposed(by: disposeBag)

        self.cardNumber.bind(to: self.cardNumberLabel.rx.text)
            .disposed(by: disposeBag)

        self.validFromDate.bind(to: self.validFromDateLabel.rx.text)
            .disposed(by: disposeBag)

        self.validThruDate.bind(to: self.validThruDateLabel.rx.text)
            .disposed(by: disposeBag)

        self.cvvNumber.bind(to: self.cvvNumberLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

//MARK: - CreditCardViewProtocol
extension CreditCardView: CreditCardViewProtocol {

    func onCardHolderNameChanged(_ text: String) {
        if text.isEmpty {
            self.cardHolderName.accept(CardDefaultValues.cardHolderName)
        } else {
            self.cardHolderName.accept(text.uppercased())
        }
    }

    func onCardNumberChanged(_ text: String) {
        if text.isEmpty {
            self.cardNumber.accept(CardDefaultValues.cardNumber)
        } else {
            let updated = CardDefaultValues.cardNumber.replacingCharacters(in: text.startIndex..<text.endIndex, with: text)
            self.cardNumber.accept(updated)
        }
    }

    func onValidFromDateChanged(_ text: String) {
        if text.isEmpty {
            self.validFromDate.accept(CardDefaultValues.validFromDate)
        } else {
            self.validFromDate.accept(text)
        }
    }

    func onValidThruDateChanged(_ text: String) {
        if text.isEmpty {
            self.validThruDate.accept(CardDefaultValues.validThruDate)
        } else {
            self.validThruDate.accept(text)
        }
    }

    func onCVVNumberChanged(_ text: String) {
        if text.isEmpty {
            self.cvvNumber.accept(CardDefaultValues.cvvNumber)
        } else {
            self.cvvNumber.accept(text.map { _ in return "●" }.joined())
        }
    }

    func flipWith(_ showingBack: Bool) {
        if var showingSide = frontView, var hiddenSide = backView {
            if !showingBack {
                (showingSide, hiddenSide) = (backView, frontView)
            }
            UIView.transition(from:showingSide,
                              to: hiddenSide,
                              duration: 0.7,
                              options: [UIView.AnimationOptions.transitionFlipFromRight, UIView.AnimationOptions.showHideTransitionViews],
                              completion: nil)
        }
    }
}
