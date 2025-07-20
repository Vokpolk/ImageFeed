//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Александр Клопков on 14.07.2025.
//
@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallUpdateTableViewAnimated() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter(view: viewController)
        viewController.configure(presenter)
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertFalse(viewController.updateTableViewAnimatedCalled)
    }
}
