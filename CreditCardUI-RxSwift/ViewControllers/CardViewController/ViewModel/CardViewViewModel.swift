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

class CardViewViewModel: ValidationViewModel {

    func transform(input: Input) -> Output {
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
                return current.format(ValidateFormate.cardNumer.rawValue,
                                      oldString: previous)
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
                return current.format(ValidateFormate.date.rawValue,
                                      oldString: previous)
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
                return current.format(ValidateFormate.date.rawValue,
                                      oldString: previous)
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
                return current.format(ValidateFormate.cvv.rawValue,
                                      oldString: previous)
            })
            .asDriver(onErrorDriveWith: .empty())

        return Output(formatedCardHolderName: cardHolderName,
                      formatedCardNumber: cardNumber,
                      formatedValidFromDate: validFromDate,
                      formatedvalidThruDate: validThruDate,
                      formatedCVVumber: cvvNumber)
    }
}

extension CardViewViewModel {
    struct Input {
        let cardHolderName: Observable<String>
        let cardNumber: Observable<String>
        let validFromDate: Observable<String>
        let validThruDate : Observable<String>
        let cvvNumber : Observable<String>
    }

    struct Output {
        let formatedCardHolderName: Driver<String>
        let formatedCardNumber: Driver<String>
        let formatedValidFromDate: Driver<String>
        let formatedvalidThruDate: Driver<String>
        let formatedCVVumber: Driver<String>
    }
}
