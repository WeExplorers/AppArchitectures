//
//  Navigator.swift
//  MVVMRxSwiftNavigator
//
//  Created by Evan Xie on 2020/4/16.
//  Copyright © 2020 UPTech Team. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SafariServices

protocol Navigatable {
    var navigator: Navigator! { get set }
}

class Navigator {
    
    static var `default` = Navigator()

    // MARK: - segues list, all app scenes
    enum Scene {
        case repositoryList(RepositoryListViewModel)
        case languages(LanguageListViewModel)
        case repository(URL)
    }

    enum Transition {
        case root(in: UIWindow)
        case modal
        case detail
        case alert
        case custom
    }

    func pop(sender: UIViewController?, toRoot: Bool = false) {
        if toRoot {
            sender?.navigationController?.popToRootViewController(animated: true)
        } else {
            sender?.navigationController?.popViewController(animated: true)
        }
    }

    func dismiss(sender: UIViewController?) {
        sender?.navigationController?.dismiss(animated: true, completion: nil)
    }

    // MARK: - invoke a single segue
    func show(segue: Scene, sender: UIViewController?, transition: Transition = .detail) {
        if let target = get(segue: segue) {
            show(target: target, sender: sender, transition: transition)
        }
    }
}

fileprivate extension Navigator {
    
    func show(target: UIViewController, sender: UIViewController?, transition: Transition) {
        switch transition {
        case .root(in: let window):
            window.rootViewController = target
            return
        case .custom: return
        default: break
        }

        guard let sender = sender else {
            fatalError("You need to pass in a sender for .navigation or .modal transitions")
        }

        if let nav = sender as? UINavigationController {
            //push root controller on navigation stack
            nav.pushViewController(target, animated: false)
            return
        }

        switch transition {
        case .modal:
            // present modally
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: target)
                sender.present(nav, animated: true, completion: nil)
            }
        case .detail:
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: target)
                sender.showDetailViewController(nav, sender: nil)
            }
        case .alert:
            DispatchQueue.main.async {
                sender.present(target, animated: true, completion: nil)
            }
        default: break
        }
    }
    
    func get(segue: Scene) -> UIViewController? {
        switch segue {
        case .repositoryList(let viewModel):
            let viewController = RepositoryListViewController.initFromStoryboard(name: "Main")
            viewController.viewModel = viewModel
            viewController.navigator = self
            return UINavigationController(rootViewController: viewController)
            
        case .languages(let viewModel):
            let viewController = LanguageListViewController.initFromStoryboard(name: "Main")
            viewController.viewModel = viewModel
            viewController.navigator = self
            return viewController
            
        case .repository(let url):
            return SFSafariViewController(url: url)
        }
    }
}
