//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Александр Клопков on 15.07.2025.
//
import Foundation
import Kingfisher

public protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func updateAvatar()
    func profileLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileLogoutService = ProfileLogoutService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(view: ProfileViewControllerProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        updateProfileDetails()
        view?.makeViewsInits()
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            updateAvatar()
        }
        updateAvatar()
    }
    
    func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            return
        }
        view?.updateAvatar(url: url)
    }
    
    func profileLogout() {
        profileLogoutService.logout()
    }
    
    private func updateProfileDetails() {
        guard let profile = ProfileService.shared.profile else { return }
        view?.updateProfileDetails(profile: profile)
    }
}
