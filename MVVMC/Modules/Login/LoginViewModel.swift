//
//  LoginViewModel.swift
//  MVVMC
//
//  Created by Evan Xie on 2020/1/22.
//  Copyright © 2020 Evan Xie. All rights reserved.
//

import RxSwift
import RxCocoa

final class LoginViewModel: BaseViewModel, ViewModelInputOutput {
    
    struct Input {
        var username: Driver<String>
        var passcode: Driver<String>
        var loginTrigger: Driver<Void>
    }
    
    struct Output {
        var isUsernameValid: Driver<Bool>
        var isPasscodeValid: Driver<Bool>
        var isEverythingValid: Driver<Bool>
        var showMessage: Driver<String>
    }
    
    func transform(input: LoginViewModel.Input) -> LoginViewModel.Output {
        
        let messageSubject = PublishRelay<String>()
        
        let usernameValid = input.username.map { [unowned self] (username) -> Bool in
            do {
                try validate(username, using: self.usernameValidator)
                return true
            } catch {
                messageSubject.accept(error.localizedDescription)
                return false
            }
        }
        
        let passcodeValid = input.passcode.map { [unowned self] (passcode) -> Bool in
            do {
                try validate(passcode, using: self.passcodeValidator)
                return true
            } catch {
                messageSubject.accept(error.localizedDescription)
                return false
            }
        }
        
        let everythingValid = Driver.combineLatest(usernameValid, passcodeValid) { $0 && $1 }
        
        input.loginTrigger.drive(onNext: { [weak self] (_) in
            self?.startLoading()
        }).disposed(by: rx.disposeBag)
        
        return Output(
            isUsernameValid: usernameValid,
            isPasscodeValid: passcodeValid,
            isEverythingValid: everythingValid,
            showMessage: messageSubject.asDriver(onErrorJustReturn: "")
        )
    }
}

fileprivate extension LoginViewModel {
    
    var usernameValidator: Validator<String> {
        return Validator<String> { username in
            try validate(username.count >= 3, errorMessage: "Username must have 3 characters at least")
            
            let hasUpperLetter = username.lowercased() != username
            let hasLowerLetter = username.uppercased() != username
            try validate(hasUpperLetter && hasLowerLetter, errorMessage: "Username must contain both lower and upper case letters")
        }
    }
    
    var passcodeValidator: Validator<String> {
        return Validator<String> { passcode in
            try validate(passcode.count >= 6, errorMessage: "Passcode must have 6 characters at least")
        }
    }
}
