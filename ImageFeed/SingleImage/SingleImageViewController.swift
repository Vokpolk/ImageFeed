//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Александр Клопков on 04.05.2025.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    // MARK: - Public Properties
    var fullImageUrl: String?
    
    // MARK: - IB Outlets
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var imageView: UIImageView!
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureScrollView()
        loadFullImageIfNeeded()
    }
    
    // MARK: - Public Methods
    func setImage(with fullImageURL: String) {
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(
            with: URL(string: fullImageURL)
        ) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showError()
            }
        }
    }
    // MARK: - IB Actions
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true)
    }
    
    // MARK: - Private Methods
    private func configureScrollView() {
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    
    private func loadFullImageIfNeeded() {
        guard let fullImageUrl else { return }
        setImage(with: fullImageUrl)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        // Этот метод из учебника, и если оставить scale ниже,
        // то итоговое фото будет очень маленькое.
        // Мне кажется, что scale = 1, идеально подходит для полноразмерного просмотра
        //scrollView.setZoomScale(scale, animated: false)
        scrollView.setZoomScale(1, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать еще раз?",
            preferredStyle: .alert
        )
        let noAction = UIAlertAction(title: "Не надо", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        let tryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            guard let self, let fullImageUrl else {
                alert.dismiss(animated: true)
                return
            }
            self.imageView.kf.setImage(
                with: URL(string: fullImageUrl)
            ) { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                
                guard let self = self else { return }
                switch result {
                case .success(let imageResult):
                    self.rescaleAndCenterImageInScrollView(image: imageResult.image)
                case .failure:
                    self.showError()
                }
            }
        }
        alert.addAction(noAction)
        alert.addAction(tryAction)
        present(alert, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let scrolViewSize = scrollView.bounds.size
        let imageSize = imageView.frame.size
        
        let horizontalInset = max((scrolViewSize.width - imageSize.width) / 2, 0)
        let verticalInset = max((scrolViewSize.height - imageSize.height) / 2, 0)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
}
