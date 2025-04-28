//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Александр Клопков on 27.04.2025.
//
import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImagge: UIImageView!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
}
