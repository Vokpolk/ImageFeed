//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Александр Клопков on 27.04.2025.
//
import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
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
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: Constants.activeImage) : UIImage(named: Constants.noActiveImage)
        likeButton.setImage(likeImage, for: .normal)
    }
    
    @IBAction private func tapLikeButton(_ sender: Any) {
        delegate?.imagesListCellDidTapLike(self)
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
