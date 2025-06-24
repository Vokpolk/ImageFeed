//
//  PhotoLikeResult.swift
//  ImageFeed
//
//  Created by Александр Клопков on 24.06.2025.
//

import UIKit

struct PhotoLikeResult: Codable {
    let photoResult: PhotoResult
    
    private enum CodingKeys: String, CodingKey {
        case photoResult = "photo"
    }
}
