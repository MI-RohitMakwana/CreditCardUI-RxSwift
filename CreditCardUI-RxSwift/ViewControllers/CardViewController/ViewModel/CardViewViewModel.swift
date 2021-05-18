//
//  CardViewViewModel.swift
//  CreditCardUI-RxSwift
//
//  Created by mind-0023 on 13/05/21.
//

import Foundation
import RxSwift
import RxCocoa

enum ValidateFormate:String {
    case cardNumer = "nnnn nnnn nnnn nnnn"
    case date = "nn/nn"
    case cvv = "nnn"
}

protocol ValidationViewModel {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}

struct CardData  {
    let cardHolderName: String
    let cardNumber: String
    let validFromDate: String
    let validThruDate : String
    let cvvNumber : String
}

class CardViewViewModel: ValidationViewModel {

    func transform(input: Input) -> Output {

        let fieldsObservable = Observable.combineLatest(input.cardHolderName.asObservable(),
                                          input.cardNumber.asObservable(),
                                          input.validFromDate.asObservable(),
                                          input.validThruDate.asObservable(),
                                          input.cvvNumber.asObservable())

        let isEnableAdd = fieldsObservable
            .map { (cardHolderName, cardNumber, validFromDate, validThruDate, cvvNumber) in
                return cardHolderName.count > 5 &&
                    cardHolderName.count < 40 &&
                    cardNumber.count == 19 &&
                    validFromDate.count == 5 &&
                    validThruDate.count == 5 &&
                    cvvNumber.count == 3
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)

        let cardAdded = input.addButtonEvent.asObservable()
            .withLatestFrom(fieldsObservable)
            .map { values in
                return CardData(cardHolderName: values.0,
                                cardNumber: values.1,
                                validFromDate: values.2,
                                validThruDate: values.3,
                                cvvNumber: values.4)
            }
            .asDriver(onErrorDriveWith: .empty())
        
        let cardHolderName = input.cardHolderName
            .scan([]) { (previous, current) in
                return Array(previous + [current]).suffix(2)
            }
            .map({ lastTwoOptions -> String in
                let _ = lastTwoOptions.first
                let currentOptions = lastTwoOptions.last
                return currentOptions ?? ""
            })
            .asDriver(onErrorDriveWith: .empty())

        let cardNumber = input.cardNumber
            .scan([]) { (previous, current) in
                return Array(previous + [current]).suffix(2)
            }
            .map({ lastTwoOptions -> String in
                guard let previous = lastTwoOptions.first,
                      let current = lastTwoOptions.last else {
                    return ""
                }
                let cardNumber = current.format(ValidateFormate.cardNumer.rawValue,
                                        oldString: previous)
                return cardNumber
            })
            .asDriver(onErrorDriveWith: .empty())

        let validFromDate = input.validFromDate
            .scan([]) { (previous, current) in
                return Array(previous + [current]).suffix(2)
            }
            .map({ lastTwoOptions -> String in
                guard let previous = lastTwoOptions.first,
                      let current = lastTwoOptions.last else {
                    return ""
                }
                let validFromDate = current.format(ValidateFormate.date.rawValue,
                                                oldString: previous)
                return validFromDate
            })
            .asDriver(onErrorDriveWith: .empty())

        let validThruDate = input.validThruDate
            .scan([]) { (previous, current) in
                return Array(previous + [current]).suffix(2)
            }
            .map({ lastTwoOptions -> String in
                guard let previous = lastTwoOptions.first,
                      let current = lastTwoOptions.last else {
                    return ""
                }
                let validFromDate = current.format(ValidateFormate.date.rawValue,
                                                oldString: previous)
                return validFromDate
            })
            .asDriver(onErrorDriveWith: .empty())

        let cvvNumber = input.cvvNumber
            .scan([]) { (previous, current) in
                return Array(previous + [current]).suffix(2)
            }
            .map({ lastTwoOptions -> String in
                guard let previous = lastTwoOptions.first,
                      let current = lastTwoOptions.last else {
                    return ""
                }
                let cvvNumber = current.format(ValidateFormate.cvv.rawValue,
                                                oldString: previous)
                return cvvNumber
            })
            .asDriver(onErrorDriveWith: .empty())

        return Output(formatedCardHolderName: cardHolderName,
                      formatedCardNumber: cardNumber,
                      formatedValidFromDate: validFromDate,
                      formatedvalidThruDate: validThruDate,
                      formatedCVVumber: cvvNumber,
                      cardAdded: cardAdded,
                      isEnableAdd: isEnableAdd)
    }
}

extension CardViewViewModel {
    struct Input {
        let cardHolderName: Observable<String>
        let cardNumber: Observable<String>
        let validFromDate: Observable<String>
        let validThruDate : Observable<String>
        let cvvNumber : Observable<String>
        let addButtonEvent : Observable<Void>
    }

    struct Output {
        let formatedCardHolderName: Driver<String>
        let formatedCardNumber: Driver<String>
        let formatedValidFromDate: Driver<String>
        let formatedvalidThruDate: Driver<String>
        let formatedCVVumber: Driver<String>
        let cardAdded: Driver<CardData>
        let isEnableAdd: Driver<Bool>
    }
}
