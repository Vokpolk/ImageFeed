//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Александр Клопков on 22.06.2025.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private let oauthTokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imagesListService = ImagesListService.shared
    
    private init() {}
    
    func logout() {
        cleanCookies()
        
        oauthTokenStorage.removeAuthToken()
        profileService.profile = nil
        profileImageService.avatarURL = nil
        imagesListService.photos.removeAll()
        //alexanderklopkov@mail.ru
        //xuJdo8-xacveg-woskun
        let loginVC = SplashViewController()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = loginVC
            // анимация перехода
            UIView.transition(
                with: window,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: nil
            )
        }
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { record in
            record.forEach { record in
                WKWebsiteDataStore.default().removeData(
                    ofTypes: record.dataTypes,
                    for: [record],
                    completionHandler: {}
                )
            }
        }
    }
}
