//
//  Photo.swift
//  ImageFeed
//
//  Created by Александр Клопков on 24.06.2025.
//

import UIKit

public struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let largeImageURL: String
    let thumbImageURL: String
    var isLiked: Bool
}
