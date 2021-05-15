//
//  CardViewController.swift
//  CreditCardUI-RxSwift
//
//  Created by mind-0023 on 12/05/21.
//

import UIKit
import RxSwift
import RxCocoa

class CardViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet fileprivate weak var creditCardView: CreditCardView!
    @IBOutlet fileprivate weak var cardHolderTextField: LineTextField!
    @IBOutlet fileprivate weak var cardNumberTextField: LineTextField!
    @IBOutlet fileprivate weak var validFromTextField: LineTextField!
    @IBOutlet fileprivate weak var validThruTextField: LineTextField!
    @IBOutlet fileprivate weak var cvvTextField: LineTextField!

    // MARK: - Properties
    fileprivate let disposeBag = DisposeBag()
    var viewModel: CardViewViewModel!
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialization()
    }
}


// MARK:- Setup UI & Config View
extension CardViewController {

    fileprivate func initialization() {
        viewModel = CardViewViewModel()
        configure(with: viewModel)
        createCVVTextFieldEventBinding()
        activeBorderFor()
    }

    // Create CVVTextField Event Binding
    private func createCVVTextFieldEventBinding() {
        cvvTextField.rx.controlEvent(UIControl.Event.editingDidBegin).subscribe { (_) in
            self.creditCardView.flipWith(true)
        }.disposed(by: disposeBag)

        cvvTextField.rx.controlEvent(UIControl.Event.editingDidEnd).subscribe { (_) in
            self.creditCardView.flipWith(false)
        }.disposed(by: disposeBag)
    }

    //Config with Input & Output
    private func configure(with viewModel: CardViewViewModel) {

        let input = CardViewViewModel.Input(
            cardHolderName: cardHolderTextField.rx.text.orEmpty.asObservable(),
            cardNumber: cardNumberTextField.rx.text.orEmpty.asObservable(),
            validFromDate: validFromTextField.rx.text.orEmpty.asObservable(),
            validThruDate: validThruTextField.rx.text.orEmpty.asObservable(),
            cvvNumber: cvvTextField.rx.text.orEmpty.asObservable()
        )

        let output = viewModel.transform(input: input)
        output.formatedCardHolderName
            .drive(onNext: { [weak self] text in
                self?.cardHolderTextField.text = text
                self?.creditCardView.onCardHolderNameChanged(text)
                self?.activeBorderFor(self?.cardHolderTextField)

            }).disposed(by: disposeBag)

        output.formatedCardNumber
            .drive(onNext: { [weak self] text in
                self?.cardNumberTextField.text = text
                self?.creditCardView.onCardNumberChanged(text)
                self?.activeBorderFor(self?.cardNumberTextField)

            }).disposed(by: disposeBag)

        output.formatedValidFromDate
            .drive(onNext: { [weak self] text in
                self?.validFromTextField.text = text
                self?.creditCardView.onValidFromDateChanged(text)
                self?.validFromTextField.textColor = self?.isValidDate(text) ?? true ? .black : .red
                self?.activeBorderFor(self?.validFromTextField)

            }).disposed(by: disposeBag)

        output.formatedvalidThruDate
            .drive(onNext: { [weak self] text in
                self?.validThruTextField.text = text
                self?.creditCardView.onValidThruDateChanged(text)
                self?.validThruTextField.textColor = self?.isValidDate(text, isFromDate: false) ?? true ? .black : .red
                self?.activeBorderFor(self?.validThruTextField)

            }).disposed(by: disposeBag)

        output.formatedCVVumber
            .drive(onNext: { [weak self] text in
                self?.cvvTextField.text = text
                self?.creditCardView.onCVVNumberChanged(text)
                self?.activeBorderFor(self?.cvvTextField)
            }).disposed(by: disposeBag)
    }
}

//MARK:- Helper Methods
extension CardViewController {

    fileprivate func isValidDate(_ date: String, isFromDate: Bool = true) -> Bool {
        guard date.count == 5 else { return true }
        let comp = date.components(separatedBy: "/")
        let calYear = String(Calendar.current.component(.year, from: Date())).suffix(2)
        let calMonth = Calendar.current.component(.month, from: Date())

        if let month = comp.first, let monthNum = Int(month),
           let year = comp.last, let yearNum = Int(year),
           let calYearNum = Int(calYear) {

            if yearNum == calYearNum && monthNum == calMonth {
                return true
            }

            if isFromDate {
                if yearNum == calYearNum && monthNum < calMonth && monthNum > 0 ||
                    yearNum < calYearNum && monthNum <= 12 && monthNum > 0{
                    return true
                }
            } else {
                if yearNum == calYearNum && monthNum > calMonth ||
                    yearNum > calYearNum && monthNum <= 12 {
                    return true
                }
            }
        }
        return false
    }

    // Set active underline
    func activeBorderFor(_ textField: LineTextField? = nil) {
        self.cardHolderTextField.lineBackgroundColor = .lightGray
        self.cardNumberTextField.lineBackgroundColor = .lightGray
        self.validFromTextField.lineBackgroundColor = .lightGray
        self.validThruTextField.lineBackgroundColor = .lightGray
        self.cvvTextField.lineBackgroundColor = .lightGray
        if let textField = textField {
            textField.lineBackgroundColor = UIColor.cardGradientBottom
        }
    }
}
