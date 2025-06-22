//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Александр Клопков on 27.04.2025.
//
import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    private var imagesListService = ImagesListService.shared
    var idPhoto: String?
    
    @IBOutlet weak var cellImagge: UIImageView!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var backgroundGradientView: UIView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImagge.kf.cancelDownloadTask()
    }
    
    func setIdPhoto(_ id: String) {
        idPhoto = id
    }
    
    @IBAction func tapLikeButton(_ sender: Any) {
        guard let idPhoto else {
            return
        }
        if let index = imagesListService.photos.firstIndex(where: {$0.id == idPhoto}) {
            if imagesListService.photos[index].isLiked {
                imagesListService.changeLike(
                    photoId: idPhoto,
                    isLike: false, completion: {result in
                        switch result {
                        case .success(let success):
                            print(success)
                        case .failure(let failure):
                            print(failure)
                        }
                    }
                )
            } else {
                imagesListService.changeLike(
                    photoId: idPhoto,
                    isLike: true, completion: {result in
                        switch result {
                        case .success(let success):
                            print(success)
                        case .failure(let failure):
                            print(failure)
                        }
                    }
                )
            }
        }
    }
}

extension UIView {
    func addGradient(colors: [UIColor], cornerRadius: CGFloat = 0) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map{ $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.cornerRadius = cornerRadius
        gradientLayer.frame = bounds
        gradientLayer.opacity = 0.1
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
