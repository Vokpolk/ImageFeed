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
    static let defaulBaseURL = URL(string: "https://api.unsplash.com")!
    
    static let activeImage = "Active"
    static let noActiveImage = "No Active"
}

