//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Александр Клопков on 14.07.2025.
//
@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsUpdateAvatar() {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(view: viewController)
        viewController.configure(presenter)
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertFalse(viewController.updateAvatarCalled)
    }
    
    func testPresenterCallsUpdateProfileDetails() {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(view: viewController)
        viewController.configure(presenter)
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertFalse(viewController.updateProfileDetailsCalled)
    }
    
    func testPresenterCallsMakeViewsInits() {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(view: viewController)
        viewController.configure(presenter)
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewController.makeViewsInitsCalled)
    }
}
