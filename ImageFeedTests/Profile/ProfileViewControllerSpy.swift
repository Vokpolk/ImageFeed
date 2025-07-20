//
//  ProfileViewControllerSpy.swift
//  ImageFeed
//
//  Created by Александр Клопков on 16.07.2025.
//

import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var updateAvatarCalled: Bool = false
    var updateProfileDetailsCalled: Bool = false
    var makeViewsInitsCalled: Bool = false

    var presenter: ProfilePresenterProtocol?
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    func updateAvatar(url: URL) {
        updateAvatarCalled = true
    }
    
    func updateProfileDetails(profile: ImageFeed.Profile) {
        updateProfileDetailsCalled = true
    }
    
    func makeViewsInits() {
        makeViewsInitsCalled = true
    }
    
    
}
