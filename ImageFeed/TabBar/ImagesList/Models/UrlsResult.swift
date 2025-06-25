//
//  UrlsResult.swift
//  ImageFeed
//
//  Created by Александр Клопков on 24.06.2025.
//
import UIKit

struct UrlsResult: Codable {
    let full: URL
    let thumb: URL
    
    private enum CodingKeys: String, CodingKey {
        case full = "full"
        case thumb = "thumb"
    }
}
