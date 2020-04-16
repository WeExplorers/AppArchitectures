//
//  RepositoryListViewController.swift
//  RepoSearcher
//
//  Created by Arthur Myronenko on 6/29/17.
//  Copyright © 2017 UPTech Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices

/// Shows a list of most starred repositories filtered by language.
class RepositoryListViewController: UIViewController, StoryboardInitializable, Navigatable {
    
    var navigator: Navigator!

    @IBOutlet private weak var tableView: UITableView!
    private let chooseLanguageButton = UIBarButtonItem(barButtonSystemItem: .organize, target: nil, action: nil)
    private let refreshControl = UIRefreshControl()

    var viewModel: RepositoryListViewModel!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBindings()

        refreshControl.sendActions(for: .valueChanged)
    }

    private func setupUI() {
        navigationItem.rightBarButtonItem = chooseLanguageButton

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.insertSubview(refreshControl, at: 0)
    }

    private func setupBindings() {

        // View Model outputs to the View Controller
        
        let input = RepositoryListViewModel.Input(reload: refreshControl.rx.controlEvent(.valueChanged).asObservable())
        let output = viewModel.transform(input: input)

        output.repositories
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                self?.refreshControl.endRefreshing()
            })
            .bind(to: tableView.rx.items(cellIdentifier: "RepositoryCell", cellType: RepositoryCell.self)) { [weak self] (_, repo, cell) in
                self?.setupRepositoryCell(cell, repository: repo)
            }.disposed(by: disposeBag)

        output.title
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)

        output.alertMessage
            .subscribe(onNext: { [weak self] in
                self?.presentAlert(message: $0)
            }).disposed(by: disposeBag)
        
        chooseLanguageButton.rx.tap
            .subscribe(onNext: { [unowned self]  (_) in
                let vm = LanguageListViewModel()
                self.navigator.show(segue: .languages(vm), sender: self, transition: .modal)
            }).disposed(by: disposeBag)
        
        tableView.rx.modelSelected(RepositoryViewModel.self)
            .subscribe(onNext: { [unowned self] (vm) in
                self.navigator.show(segue: .repository(vm.url), sender: self, transition: .detail)
            }).disposed(by: disposeBag)
    }

    private func setupRepositoryCell(_ cell: RepositoryCell, repository: RepositoryViewModel) {
        cell.selectionStyle = .none
        cell.setName(repository.name)
        cell.setDescription(repository.description)
        cell.setStarsCountTest(repository.starsCountText)
    }

    private func presentAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
    }
}
