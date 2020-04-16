//
//  RepositoryListViewModel.swift
//  RepoSearcher
//
//  Created by Arthur Myronenko on 6/29/17.
//  Copyright © 2017 UPTech Team. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class RepositoryListViewModel: InputOutputTransformable {
    
    struct Input {

        /// Call to reload repositories.
        let reload: Observable<Void>
    }
    
    struct Output {
        
        /// Emits an array of fetched repositories.
        let repositories: Observable<[RepositoryViewModel]>

        /// Emits a formatted title for a navigation item.
        let title: Observable<String>

        /// Emits an error messages to be shown.
        let alertMessage: Observable<String>
    }

    /// Call to update current language. Causes reload of the repositories.
    var setCurrentLanguage: AnyObserver<String> {
        return currentLanguage.asObserver()
    }
    
    fileprivate let githubService: GithubService
    fileprivate let disposeBag = DisposeBag()

    fileprivate let currentLanguage: BehaviorSubject<String>

    init(initialLanguage: String, githubService: GithubService = GithubService()) {
        self.githubService = githubService
        self.currentLanguage = BehaviorSubject(value: initialLanguage)
    }
    
    func transform(input: Input) -> Output {
        
        let alertMessage = PublishRelay<String>()
        
        // 获取仓库列表
        let repositories = Observable.combineLatest(input.reload, currentLanguage.asObservable()).flatMapLatest {
                self.githubService.getMostPopularRepositories(byLanguage: $0.1)
        }.catchError { (error) -> Observable<[Repository]> in
            alertMessage.accept(error.localizedDescription)
            return Observable.empty()
        }.map { repositories in
            // 将仓库列表转换成 RepositoryViewModel
            repositories.map { RepositoryViewModel(repository: $0) }
        }
        
        return Output(
            repositories: repositories,
            title: currentLanguage.asObservable(),
            alertMessage: alertMessage.asObservable()
        )
    }
}
