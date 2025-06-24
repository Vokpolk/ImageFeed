//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Александр Клопков on 24.06.2025.
//

import UIKit

struct PhotoResult: Codable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let isLiked: Bool
    let description: String?
    let images: UrlsResult
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case createdAt = "created_at"
        case width = "width"
        case height = "height"
        case isLiked = "liked_by_user"
        case description = "description"
        case images = "urls"
    }
}
