//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Александр Клопков on 22.05.2025.
//
import UIKit

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    
    let tokenKey = "Bearer Token"
    
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            if UserDefaults.standard.string(forKey: tokenKey) != nil {
                print(UserDefaults.standard.string(forKey: tokenKey)!)
                return
            }
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
    
    private init() {}
}
