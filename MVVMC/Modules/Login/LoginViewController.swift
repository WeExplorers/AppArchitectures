//
//  LoginViewController.swift
//  MVVMC
//
//  Created by Evan Xie on 2020/1/22.
//  Copyright © 2020 Evan Xie. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

final class LoginViewController: ViewModelViewController<LoginViewModel> {
    
    fileprivate var errorMessageLabel: UILabel!
    
    fileprivate var usernameTextFiled: UITextField!
    fileprivate var passcodeTextField: UITextField!
    fileprivate var loginButton: UIButton!
    
    override func buildUI() {
        
        errorMessageLabel = UILabel()
        errorMessageLabel.text = ""
        errorMessageLabel.numberOfLines = 0
        errorMessageLabel.textColor = .red
        
        usernameTextFiled = UITextField()
        usernameTextFiled.borderStyle = .roundedRect
        usernameTextFiled.placeholder = "Enter your username"
        passcodeTextField = UITextField()
        passcodeTextField.placeholder = "Enter your passcode"
        passcodeTextField.isSecureTextEntry = true
        passcodeTextField.borderStyle = .roundedRect
        passcodeTextField.clearButtonMode = .whileEditing
        
        loginButton = UIButton(type: .custom)
        loginButton.layer.cornerRadius = 4
        loginButton.layer.borderWidth = 0.5
        loginButton.layer.borderColor = UIColor.darkGray.cgColor
        loginButton.setTitleColor(.orange, for: .normal)
        loginButton.setTitleColor(.cyan, for: .highlighted)
        loginButton.setTitleColor(.gray, for: .disabled)
        loginButton.setTitle("Login", for: .normal)
        
        view.addSubview(errorMessageLabel)
        view.addSubview(usernameTextFiled)
        view.addSubview(passcodeTextField)
        view.addSubview(loginButton)
        
        errorMessageLabel.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(40)
            maker.right.equalToSuperview().offset(-40)
            maker.top.equalToSuperview().offset(view.safeAreaInsets.top + 80)
        }
        
        usernameTextFiled.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(30)
            maker.right.equalToSuperview().offset(-30)
            maker.top.equalTo(errorMessageLabel.snp.bottom).offset(20)
            maker.height.equalTo(40)
        }
        
        passcodeTextField.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(30)
            maker.right.equalToSuperview().offset(-30)
            maker.top.equalTo(usernameTextFiled.snp.bottom).offset(20)
            maker.height.equalTo(40)
        }
        
        loginButton.snp.makeConstraints { (maker) in
            maker.top.equalTo(passcodeTextField.snp.bottom).offset(30)
            maker.width.equalTo(120)
            maker.height.equalTo(40)
            maker.centerX.equalToSuperview()
        }
    }
    
    override func bindViewModel() {
        
        super.bindViewModel()
        
        let input = LoginViewModel.Input(
            username: usernameTextFiled.rx.text.orEmpty.asDriver(),
            passcode: passcodeTextField.rx.text.orEmpty.asDriver(),
            loginTrigger: loginButton.rx.tap.asDriver()
        )
        
        // When we are in logging state, disable user interaction.
        viewModel.loading.map { !$0 }
            .bind(to: view.rx.isUserInteractionEnabled)
            .disposed(by: rx.disposeBag)
        
        // Provide inputs for view model，then view model generates outputs.
        let output = viewModel.transform(input: input)
        
        // Only usename and passcode both are valid, then login button can be touchable.
        output.isEverythingValid.drive(loginButton.rx.isEnabled).disposed(by: rx.disposeBag)
        
        output.isUsernameValid.drive(onNext: { (valid) in
            if valid {
                self.errorMessageLabel.text = ""
            }
        }).disposed(by: rx.disposeBag)
        
        output.isPasscodeValid.drive(onNext: { (valid) in
            if valid {
                self.errorMessageLabel.text = ""
            }
        }).disposed(by: rx.disposeBag)
        
        output.isEverythingValid.drive(onNext: { (valid) in
            if valid {
                self.errorMessageLabel.text = ""
            }
        }).disposed(by: rx.disposeBag)
        
        // Bind error message to `errorMessageLabel`
        output.showMessage.drive(errorMessageLabel.rx.text).disposed(by: rx.disposeBag)
    }

}

