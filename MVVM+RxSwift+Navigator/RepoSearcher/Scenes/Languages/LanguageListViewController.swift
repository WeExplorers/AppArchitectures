//
//  LanguageListViewController.swift
//  RepoSearcher
//
//  Created by Arthur Myronenko on 6/30/17.
//  Copyright © 2017 UPTech Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// Shows a list languages.
class LanguageListViewController: UIViewController, StoryboardInitializable, Navigatable {
    
    var navigator: Navigator!
    
    let disposeBag = DisposeBag()
    var viewModel: LanguageListViewModel!

    @IBOutlet private weak var tableView: UITableView!
    private let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBindings()
    }

    private func setupUI() {
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.title = "Choose a language"

        tableView.rowHeight = 48.0
    }

    private func setupBindings() {
        viewModel.languages
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: "LanguageCell", cellType: UITableViewCell.self)) { (_, language, cell) in
                cell.textLabel?.text = language
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(String.self)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (language) in
                // 选择一种编程语言，但如何把参数传递给 repository list view controller, 在 navigator 这种模式下，就会受到局限性。
                // 它需要上下文环境，或用 delegate 的方式，把参数传回给之前的 view controller.
                self.navigator.dismiss(sender: self)
            }).disposed(by: disposeBag)

        cancelButton.rx.tap
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (_) in
                self.navigator.dismiss(sender: self)
            }).disposed(by: disposeBag)
    }
}
