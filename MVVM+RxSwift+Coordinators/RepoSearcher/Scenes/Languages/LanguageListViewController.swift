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
class LanguageListViewController: UIViewController, StoryboardInitializable {

    let disposeBag = DisposeBag()
    var viewModel: LanguageListViewModel!

    @IBOutlet private weak var tableView: UITableView!
    private let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    
    deinit {
        print("\(self) deinit")
    }

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
        
        let input = LanguageListViewModel.Input(
            selectLanguage: tableView.rx.modelSelected(String.self).asObservable(),
            cancel: cancelButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.languages
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: "LanguageCell", cellType: UITableViewCell.self)) { (_, language, cell) in
                cell.textLabel?.text = language
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
    }
}
