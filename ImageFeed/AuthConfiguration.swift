//
//  Constants.swift
//  ImageFeed
//
//  Created by Александр Клопков on 18.05.2025.
//
import Foundation

enum Constants {
    static let accessKey = "1zmis-ojwZ3UVGn-LeCZH5oU3JyVDexhJlFQWqDn1s4"
    static let secretKey = "z-dI5CtOQ94NV_wqNhYj7GgD6M_la8La9yBIlxab6UU"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let baseURL = URL(string: "https://unsplash.com")
    static let apiURL = URL(string: "https://api.unsplash.com")
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    
    static let activeImage = "Active"
    static let noActiveImage = "No Active"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let baseURL: URL
    let apiURL: URL
    let unsplashAuthorizeURLString: String
    
    init(
        accessKey: String,
        secretKey: String,
        redirectURI: String,
        accessScope: String,
        baseURL: URL,
        apiURL: URL,
        unsplashAuthorizeURLString: String
    ) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.baseURL = baseURL
        self.apiURL = apiURL
        self.unsplashAuthorizeURLString = unsplashAuthorizeURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 baseURL: Constants.baseURL!,
                                 apiURL: Constants.apiURL!,
                                 unsplashAuthorizeURLString: Constants.unsplashAuthorizeURLString)
    }
}
