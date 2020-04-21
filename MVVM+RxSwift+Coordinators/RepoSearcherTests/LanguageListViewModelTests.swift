//
//  LanguageListViewModelTests.swift
//  RepoSearcher
//
//  Created by Arthur Myronenko on 7/12/17.
//  Copyright © 2017 UPTech Team. All rights reserved.
//

@testable import MVVMRxSwiftCoordinators
import XCTest
import RxTest
import RxSwift

class LanguageListViewModelTests: XCTestCase {

    var testScheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var githubService: GithubServiceMock!
    var viewModel: LanguageListViewModel!

    override func setUp() {
        super.setUp()

        testScheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        githubService = GithubServiceMock()
        viewModel = LanguageListViewModel(githubService: githubService)
    }

    func test_SelectLanguage_EmitsDidSelectLanguage() {
        
        let selectLanguageTrigger = testScheduler.createHotObservable([Recorded.next(300, "Java")]).asObservable()
        let cancelTrigger = PublishSubject<Void>().asObservable()
        let input = LanguageListViewModel.Input(selectLanguage: selectLanguageTrigger, cancel: cancelTrigger)
        let _ = viewModel.transform(input: input)
        
        let result = testScheduler.start { self.viewModel.scene.didSelectLanguage }
        XCTAssertEqual(result.events, [Recorded.next(300, "Java")])
    }

    func test_Cancel_EmitsDidCancel() {
        
        let selectLanguageTrigger = PublishSubject<String>().asObservable()
        let cancelTrigger = testScheduler.createHotObservable([Recorded.next(300, ())]).asObservable()
        let input = LanguageListViewModel.Input(selectLanguage: selectLanguageTrigger, cancel: cancelTrigger)
        let _ = viewModel.transform(input: input)

        let result = testScheduler.start { self.viewModel.scene.didCancel.map { true } }
        XCTAssertEqual(result.events, [Recorded.next(300, true)])
    }

    func test_Languages_EmitsResultOfRequest() {
        
        githubService.languageListReturnValue = .just(["Swift", "Objective-C"])
        viewModel = LanguageListViewModel(githubService: githubService)
        
        let selectLanguageTrigger = PublishSubject<String>()
        let cancelTrigger = PublishSubject<Void>()
        let input = LanguageListViewModel.Input(selectLanguage: selectLanguageTrigger.asObservable(), cancel: cancelTrigger.asObservable())
        let output = viewModel.transform(input: input)
        let result = testScheduler.start { output.languages }

        XCTAssertEqual(result.events.count, 2)

        guard let languagesResult = result.events.first?.value.element else {
            return XCTFail()
        }

        XCTAssertEqual(languagesResult, ["Swift", "Objective-C"])
    }
}
