//
//  BaseViewModel.swift
//  MVVMC
//
//  Created by Evan Xie on 2020/1/22.
//  Copyright © 2020 Evan Xie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ViewModelInputOutput {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}

/// 基本视图模型，可以将一些共用的东西放在此处
class BaseViewModel: NSObject {
    
    private let loadingSubject = BehaviorRelay(value: false)
    
    var loading: Observable<Bool> {
        return loadingSubject.asObservable()
    }
    
    func startLoading() {
        loadingSubject.accept(true)
    }
    
    func stopLoading() {
        loadingSubject.accept(false)
    }
}
