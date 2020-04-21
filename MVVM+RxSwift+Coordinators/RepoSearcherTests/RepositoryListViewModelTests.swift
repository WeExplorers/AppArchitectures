//
//  RepositoryListViewModelTests.swift
//  RepoSearcher
//
//  Created by Arthur Myronenko on 7/12/17.
//  Copyright © 2017 UPTech Team. All rights reserved.
//

@testable import MVVMRxSwiftCoordinators
import XCTest
import RxTest
import RxSwift

class RepositoryListViewModelTests: XCTestCase {

    let testRepository = Repository(fullName: "Full Name",
                                    description: "Description",
                                    starsCount: 3,
                                    url: "https://www.apple.com")

    var testScheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var githubService: GithubServiceMock!
    var viewModel: RepositoryListViewModel!

    override func setUp() {
        super.setUp()

        testScheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        githubService = GithubServiceMock()
        viewModel = RepositoryListViewModel(initialLanguage: "Swift", githubService: githubService)
    }

    func test_InitWithInitialLanguage_EmitsValidTitle() {
        viewModel = RepositoryListViewModel(initialLanguage: "Swift", githubService: githubService)
        
        let chooseLanguageTrigger = PublishSubject<Void>().asObservable()
        let selectRepositoryTrigger = PublishSubject<RepositoryViewModel>().asObservable()
        let reloadTrigger = PublishSubject<Void>().asObservable()
        
        let input = RepositoryListViewModel.Input(chooseLanguage: chooseLanguageTrigger, selectRepository: selectRepositoryTrigger, reload: reloadTrigger)
        let output = viewModel.transform(input: input)
        let result = testScheduler.start { output.title }
        
        XCTAssertEqual(result.events, [Recorded.next(200, "Swift")])
    }
    
    func test_Repositories_ReturnsValidViewModels() {
        let testRepository = Repository(fullName: "Full Name",
                                        description: "Description",
                                        starsCount: 3,
                                        url: "https://www.apple.com")
        githubService.repositoriesReturnValue = .just([testRepository])
        
        let chooseLanguageTrigger = PublishSubject<Void>().asObservable()
        let selectRepositoryTrigger = PublishSubject<RepositoryViewModel>().asObservable()
        let reloadTrigger = testScheduler.createHotObservable([Recorded.next(300, ())]).asObservable()
        
        let input = RepositoryListViewModel.Input(chooseLanguage: chooseLanguageTrigger, selectRepository: selectRepositoryTrigger, reload: reloadTrigger)
        let output = viewModel.transform(input: input)

        let result = testScheduler.start { output.repositories }
        XCTAssertEqual(result.events.count, 1)

        guard let repositoryViewModel = result.events.first?.value.element?.first else {
            return XCTFail()
        }

        XCTAssertEqual(repositoryViewModel.name, "Full Name")
    }

    func test_RepositoriesWithNetworkError_EmitsAlertMessage() {
        let error = NSError(domain: "Test", code: 2, userInfo: nil)
        githubService.repositoriesReturnValue = .error(error)

        let chooseLanguageTrigger = PublishSubject<Void>().asObservable()
        let selectRepositoryTrigger = PublishSubject<RepositoryViewModel>().asObservable()
        let reloadTrigger = testScheduler.createHotObservable([Recorded.next(300, ())]).asObservable()
        
        let input = RepositoryListViewModel.Input(chooseLanguage: chooseLanguageTrigger, selectRepository: selectRepositoryTrigger, reload: reloadTrigger)
        let output = viewModel.transform(input: input)


        output.repositories
            .subscribe()
            .disposed(by: disposeBag)

        let result = testScheduler.start { output.alertMessage }
        XCTAssertEqual(result.events, [Recorded.next(300, error.localizedDescription)])
    }

    func test_LanguageChange_UpdatesRepositories() {
        githubService.repositoriesReturnValue = .just([testRepository])

        let chooseLanguageTrigger = PublishSubject<Void>().asObservable()
        let selectRepositoryTrigger = PublishSubject<RepositoryViewModel>().asObservable()
        let reloadTrigger = testScheduler.createHotObservable([Recorded.next(300, ())]).asObservable()
        
        let input = RepositoryListViewModel.Input(chooseLanguage: chooseLanguageTrigger, selectRepository: selectRepositoryTrigger, reload: reloadTrigger)
        let output = viewModel.transform(input: input)
        
        testScheduler.createHotObservable([Recorded.next(400, "Objective-C")])
            .bind(to: viewModel.setCurrentLanguage)
            .disposed(by: disposeBag)

        let result = testScheduler.start { output.repositories.map({ _ in true }) }
        XCTAssertEqual(result.events, [Recorded.next(300, true), Recorded.next(400, true)])
    }

    func test_SelectRepository_EmitsShowRepository() {
        let repositoryToSelect = RepositoryViewModel(repository: testRepository)

        let chooseLanguageTrigger = PublishSubject<Void>().asObservable()
        let selectRepositoryTrigger = testScheduler.createHotObservable([Recorded.next(300, repositoryToSelect)]).asObservable()
        let reloadTrigger = PublishSubject<Void>()
        
        let input = RepositoryListViewModel.Input(chooseLanguage: chooseLanguageTrigger, selectRepository: selectRepositoryTrigger, reload: reloadTrigger)
        let _ = viewModel.transform(input: input)

        let result = testScheduler.start { self.viewModel.scene.showRepository.map { $0.absoluteString } }
        XCTAssertEqual(result.events, [Recorded.next(300, "https://www.apple.com")])
    }

    func test_ChooseLanguage_EmitsShowLanguageList() {
        
        let chooseLanguageTrigger = testScheduler.createHotObservable([Recorded.next(300, ())]).asObservable()
        let selectRepositoryTrigger = PublishSubject<RepositoryViewModel>().asObservable()
        let reloadTrigger = PublishSubject<Void>().asObservable()
        
        let input = RepositoryListViewModel.Input(chooseLanguage: chooseLanguageTrigger, selectRepository: selectRepositoryTrigger, reload: reloadTrigger)
        let _ = viewModel.transform(input: input)

        let result = testScheduler.start { self.viewModel.scene.showLanguageList.map({ true }) }
        XCTAssertEqual(result.events, [Recorded.next(300, true)])
    }
}
