//
//  CardViewController.swift
//  CreditCardUI-RxSwift
//
//  Created by mind-0023 on 12/05/21.
//

import UIKit
import RxSwift
import RxCocoa

enum DateType: String {
    case fromDate
    case thruDate
}

class CardViewController: UIViewController, UIScrollViewDelegate{

    // MARK: - IBOutlets
    @IBOutlet fileprivate weak var creditCardView: CreditCardView!
    @IBOutlet fileprivate weak var cardHolderTextField: LineTextField!
    @IBOutlet fileprivate weak var cardNumberTextField: LineTextField!
    @IBOutlet fileprivate weak var validFromTextField: DateTextField!
    @IBOutlet fileprivate weak var validThruTextField: DateTextField!
    @IBOutlet fileprivate weak var cvvTextField: LineTextField!
    @IBOutlet fileprivate weak var clearButton: UIButton!
    @IBOutlet fileprivate weak var addButton: UIButton!
    @IBOutlet fileprivate weak var cardTableView: UITableView! {
        didSet {
            cardTableView.rx.setDelegate(self).disposed(by: disposeBag)
            cardTableView.register(UITableViewCell.self,
                                   forCellReuseIdentifier: "UITableViewCell")
            self.bindDisplayingTableView()
            self.bindSelectingTableView()
        }
    }
    
    // MARK: - Properties
    fileprivate let disposeBag = DisposeBag()
    fileprivate var viewModel : CardViewViewModel!
    fileprivate var fromDate: Date?
    fileprivate var cards = BehaviorRelay<[CardData]>(value: [])
    fileprivate var isEnableAdd: Bool = false{
        didSet {
            self.addButton.isEnabled = isEnableAdd
            self.addButton.alpha = isEnableAdd ? 1 : 0.5
        }
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialization()
    }
}

// MARK:- Date Picker Botton Actions
extension CardViewController{
    @objc private func cancelAction(_ button: UIBarButtonItem) {
        if DateType(rawValue: button.accessibilityIdentifier ?? "") == DateType.fromDate {
            validFromTextField.resignFirstResponder()
        } else if DateType(rawValue: button.accessibilityIdentifier ?? "") == DateType.thruDate {
            validThruTextField.resignFirstResponder()
        }
        activeBorderFor()
    }

    @objc private func doneAction(_ button: UIBarButtonItem) {
        if DateType(rawValue: button.accessibilityIdentifier ?? "") == DateType.fromDate {
            if let datePickerView = validFromTextField.inputView as? UIDatePicker {
                validFromTextField.selectedDate = datePickerView.date
                fromDate = datePickerView.date
                validThruTextField.text = ""
                self.creditCardView.onValidThruDateChanged("")
                validFromTextField.resignFirstResponder()
            }
        } else if DateType(rawValue: button.accessibilityIdentifier ?? "") == DateType.thruDate {
            if let datePickerView = validThruTextField.inputView as? UIDatePicker {
                validThruTextField.selectedDate = datePickerView.date
                validThruTextField.resignFirstResponder()
            }
        }
        activeBorderFor()
    }
}

// MARK:- Setup UI & Config View
extension CardViewController {

    fileprivate func initialization() {
        setupUI()
        viewModel = CardViewViewModel()
        configure(with: viewModel)
        createDateTextFieldEventBinding()
        createCVVTextFieldEventBinding()
        activeBorderFor()
        bindButtons()
    }

    fileprivate func bindDisplayingTableView() {
        cards.asObservable().bind(to: cardTableView.rx.items(cellIdentifier: String(describing: UITableViewCell.self), cellType: UITableViewCell.self)) { (row,card,cell) in
            cell.textLabel?.text = card.cardHolderName
        }.disposed(by: disposeBag)
    }

    fileprivate func bindSelectingTableView() {
        cardTableView.rx.modelSelected(CardData.self).subscribe(onNext: { item in
            self.setvaluesInTextField(item)
        }).disposed(by: disposeBag)
    }

    private func bindButtons() {
        self.clearButton.rx.tap.asObservable()
            .subscribe(onNext: { _ in
//                self.resetAll()
            })
            .disposed(by: disposeBag)
    }

    private func setupUI() {
        self.addButton.applycornerRadius(5)
        self.addButton.backgroundColor = UIColor.cardGradientBottom
        self.addButton.setTitleColor(.white, for: .normal)

        self.clearButton.backgroundColor = .white
        self.clearButton.setTitleColor(UIColor.cardGradientBottom, for: .normal)
        self.clearButton.applycornerRadius(5)
        self.clearButton.applyBorder(color: UIColor.cardGradientBottom, width: 1)
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

    // Create DateTextField Event Binding
    private func createDateTextFieldEventBinding() {

        validFromTextField.rx.controlEvent(.editingDidBegin)
            .subscribe { (_) in
                self.validFromTextField.datePicker(target: self,
                                                   doneAction: #selector(self.doneAction(_:)),
                                                   cancelAction: #selector(self.cancelAction),
                                                   dateType: .fromDate,
                                                   datePickerMode: .date)
            }.disposed(by: disposeBag)

        validThruTextField.rx.controlEvent(.editingDidBegin)
            .subscribe { (_) in
                self.validThruTextField.datePicker(target: self,
                                                   doneAction: #selector(self.doneAction(_:)),
                                                   cancelAction: #selector(self.cancelAction),
                                                   minimumDate: self.validFromTextField.selectedDate ?? Date(),
                                                   dateType: .thruDate,
                                                   datePickerMode: .date)
            }.disposed(by: disposeBag)
    }

    // Config with Input & Output
    private func configure(with viewModel: CardViewViewModel) {

        let input = CardViewViewModel.Input(
            cardHolderName: cardHolderTextField.rx.text.orEmpty.asObservable(),
            cardNumber: cardNumberTextField.rx.text.orEmpty.asObservable(),
            validFromDate: validFromTextField.rx.text.orEmpty.asObservable(),
            validThruDate: validThruTextField.rx.text.orEmpty.asObservable(),
            cvvNumber: cvvTextField.rx.text.orEmpty.asObservable(),
            addButtonEvent: self.addButton.rx.tap.asObservable()
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
                self?.activeBorderFor(self?.validFromTextField)
            }).disposed(by: disposeBag)

        output.formatedvalidThruDate
            .drive(onNext: { [weak self] text in
                self?.validThruTextField.text = text
                self?.creditCardView.onValidThruDateChanged(text)
                self?.activeBorderFor(self?.validThruTextField)
            }).disposed(by: disposeBag)

        output.formatedCVVumber
            .drive(onNext: { [weak self] text in
                self?.cvvTextField.text = text
                self?.creditCardView.onCVVNumberChanged(text)
                self?.activeBorderFor(self?.cvvTextField)
            }).disposed(by: disposeBag)

        output.isEnableAdd
            .drive(onNext: { [weak self] enabled in
                self?.isEnableAdd = enabled
            }).disposed(by: disposeBag)

        output.cardAdded
            .drive(onNext: { [weak self] card in
//                self?.cards.append(card)
//                self?.resetAll()
            }).disposed(by: disposeBag)
    }
}

//MARK:- Helper Methods
extension CardViewController {

    fileprivate func resetAll() {
        resignAllTextField()
        resetFields()
    }

    // Set active underline
    fileprivate func activeBorderFor(_ textField: LineTextField? = nil) {
        cardHolderTextField.lineBackgroundColor = .lightGray
        cardNumberTextField.lineBackgroundColor = .lightGray
        validFromTextField.lineBackgroundColor = .lightGray
        validThruTextField.lineBackgroundColor = .lightGray
        cvvTextField.lineBackgroundColor = .lightGray
        if let textField = textField {
            textField.lineBackgroundColor = UIColor.cardGradientBottom
        }
    }

    fileprivate func resignAllTextField() {
        cardHolderTextField.resignFirstResponder()
        cardNumberTextField.resignFirstResponder()
        validFromTextField.resignFirstResponder()
        validThruTextField.resignFirstResponder()
        cvvTextField.resignFirstResponder()
        activeBorderFor()
    }

    fileprivate func resetFields() {
        setvaluesInTextField()
    }

    fileprivate func setvaluesInTextField(_ card: CardData? = nil) {
        cardHolderTextField.text = card?.cardHolderName
        cardNumberTextField.text = card?.cardNumber
        validFromTextField.text = card?.validFromDate
        validThruTextField.text = card?.validThruDate
        cvvTextField.text = card?.cvvNumber
    }
}
