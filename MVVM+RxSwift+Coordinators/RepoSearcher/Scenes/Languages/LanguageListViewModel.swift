//
//  LanguageListViewModel.swift
//  RepoSearcher
//
//  Created by Arthur Myronenko on 7/12/17.
//  Copyright © 2017 UPTech Team. All rights reserved.
//

import RxSwift

class LanguageListViewModel: InputOutputTransformable {

    struct Input {
        let selectLanguage: Observable<String>
        let cancel: Observable<Void>
    }
    
    struct Output {
        let languages: Observable<[String]>
    }
    
    struct Scene {
        let didSelectLanguage: Observable<String>
        let didCancel: Observable<Void>
    }
    

    let scene: Scene
    
    private let selectLanguage = PublishSubject<String>()
    private let cancel = PublishSubject<Void>()
    private let service: GithubService
    private let disposeBag = DisposeBag()
    
    deinit {
        print("\(self) deinit")
    }

    init(githubService: GithubService = GithubService()) {
        self.service = githubService
        self.scene = Scene(didSelectLanguage: selectLanguage.asObservable(), didCancel: cancel.asObservable())
    }
    
    func transform(input: Input) -> Output {
        input.selectLanguage.bind(to: selectLanguage).disposed(by: disposeBag)
        input.cancel.bind(to: cancel).disposed(by: disposeBag)
        
        return Output(languages: service.getLanguageList())
    }
}
