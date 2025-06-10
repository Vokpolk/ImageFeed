//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Александр Клопков on 22.05.2025.
//
import UIKit
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    
    let tokenKey = "Bearer Token"

    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            guard let newValue else { return }
            let isSuccess = KeychainWrapper.standard.set(newValue, forKey: tokenKey)
            if !isSuccess {
                print("APP: [OAuth2TokenStorage] [token] failed to set")
            }
        }
    }
    
    func removeAuthToken() {
        let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: tokenKey)
        if !removeSuccessful {
            print("APP: [OAuth2TokenStorage] [removeAuthToken()] failed to remove")
        }
    }
    
    private init() {}
}
