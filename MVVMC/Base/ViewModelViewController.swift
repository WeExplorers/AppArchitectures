//
//  ViewModelViewController.swift
//  MVVMC
//
//  Created by Evan Xie on 2020/1/22.
//  Copyright © 2020 Evan Xie. All rights reserved.
//

import UIKit
import RxSwift
import NSObject_Rx

class ViewModelViewController<ViewModel>: UIViewController where ViewModel: BaseViewModel {
    
    fileprivate let loadingIndicator = UIActivityIndicatorView(style: .gray)
    
    var viewModel: ViewModel!
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        bindViewModel()
    }
    
    /// Overwrite in subclass, don't forget invoking `super.buildUI()`
    func buildUI() {
        
    }
    
    /// Overwrite in subclass, don't forget invoking `super.bindViewModel()`
    func bindViewModel() {
        
        viewModel.loading
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (isLoading) in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            }).disposed(by: rx.disposeBag)
    }
}

fileprivate extension ViewModelViewController {
    
    func showLoading() {
        view.addSubview(loadingIndicator)
        loadingIndicator.center = CGPoint(x: view.center.x, y: view.center.y - 50)
        loadingIndicator.startAnimating()
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
        loadingIndicator.removeFromSuperview()
    }
}
