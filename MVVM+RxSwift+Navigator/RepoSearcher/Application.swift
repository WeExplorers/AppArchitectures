//
//  Application.swift
//  MVVMRxSwiftNavigator
//
//  Created by Evan Xie on 2020/4/16.
//  Copyright © 2020 UPTech Team. All rights reserved.
//

import Foundation
import UIKit

final class Application: NSObject {
    static let shared = Application()

    var window: UIWindow?

    let navigator: Navigator

    private override init() {
        navigator = Navigator.default
        super.init()
    }

    func presentInitialScreen(in window: UIWindow?) {
        guard let window = window else { return }
        self.window = window

        let viewModel = RepositoryListViewModel(initialLanguage: "Swift")
        navigator.show(segue: .repositoryList(viewModel), sender: nil, transition: .root(in: window))
    }
}
