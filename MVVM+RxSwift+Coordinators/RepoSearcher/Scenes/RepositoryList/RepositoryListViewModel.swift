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
        /// Call to show language list screen.
        let chooseLanguage: Observable<Void>

        /// Call to open repository page.
        let selectRepository: Observable<RepositoryViewModel>

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
    
    struct Scene {
        /// Emits an url of repository page to be shown.
        let showRepository: Observable<URL>

        /// Emits when we should show language list.
        let showLanguageList: Observable<Void>
    }

    /// Call to update current language. Causes reload of the repositories.
    var setCurrentLanguage: AnyObserver<String> {
        return currentLanguage.asObserver()
    }
    
    let scene: Scene
    
    fileprivate let githubService: GithubService
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate let showRepository = PublishRelay<URL>()
    fileprivate let showLanguageList = PublishRelay<Void>()
    fileprivate let currentLanguage: BehaviorSubject<String>

    init(initialLanguage: String, githubService: GithubService = GithubService()) {
        self.githubService = githubService
        self.currentLanguage = BehaviorSubject(value: initialLanguage)
        self.scene = Scene(showRepository: showRepository.asObservable(), showLanguageList: showLanguageList.asObservable())
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
        
        input.chooseLanguage.bind(to: showLanguageList).disposed(by: disposeBag)
        input.selectRepository.map { $0.url }.bind(to: showRepository).disposed(by: disposeBag)
        
        return Output(
            repositories: repositories,
            title: currentLanguage.asObservable(),
            alertMessage: alertMessage.asObservable()
        )
    }
}
