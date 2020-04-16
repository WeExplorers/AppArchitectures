//
//  LanguageListViewModel.swift
//  RepoSearcher
//
//  Created by Arthur Myronenko on 7/12/17.
//  Copyright © 2017 UPTech Team. All rights reserved.
//

import RxSwift

class LanguageListViewModel {

    let languages: Observable<[String]>

    init(githubService: GithubService = GithubService()) {
        self.languages = githubService.getLanguageList()
    }
}
