//
//  ImagesListViewControllerSpy.swift
//  ImageFeed
//
//  Created by Александр Клопков on 16.07.2025.
//

import ImageFeed
import Foundation

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var updateTableViewAnimatedCalled: Bool = false
    var presenter: ImagesListPresenterProtocol?
    
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    func updateTableViewAnimated() {
        updateTableViewAnimatedCalled = true
    }
}
