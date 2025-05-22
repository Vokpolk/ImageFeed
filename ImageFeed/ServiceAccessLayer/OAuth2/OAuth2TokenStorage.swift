//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Александр Клопков on 22.05.2025.
//
import UIKit

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: "Bearer Token")
        }
        set {
            if UserDefaults.standard.string(forKey: "Bearer Token") != nil {
                print(UserDefaults.standard.string(forKey: "Bearer Token")!)
                return
            }
            UserDefaults.standard.set(newValue, forKey: "Bearer Token")
        }
    }
    
    private init() {}
}
