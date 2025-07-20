//
//  ViewController.swift
//  ImageFeed
//
//  Created by Александр Клопков on 25.04.2025.
//

import UIKit

public protocol ImagesListViewControllerProtocol: AnyObject {
    func configure(_ presenter: ImagesListPresenterProtocol)
    func updateTableViewAnimated()
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    // MARK: - Private Properties
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var presenter: ImagesListPresenterProtocol!
    
    // MARK: - Private IBOutlets
    @IBOutlet weak private var tableView: UITableView!
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(
            top: 12,
            left: 0,
            bottom: 12,
            right: 0
        )
        
        presenter.fetchPhotosNextPage()
        presenter.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            viewController.fullImageUrl = presenter.getPhotos()[indexPath.row].largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Public Methods
    func configure(_ presenter: any ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    func updateTableViewAnimated() {
        let (newCount, oldCount) = presenter.updateTableViewAnimated()
        
        if oldCount != newCount {
            tableView.performBatchUpdates{
                var indexPath: [IndexPath] = []
                for i in oldCount..<newCount {
                    indexPath.append(IndexPath(row: i, section: 0))
                }
                tableView.insertRows(at: indexPath, with: .automatic)
            }
        }
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imagePlaceHolder = UIImage(named: "photo_cap")
        cell.cellImagge.kf.indicatorType = .activity
        cell.cellImagge.kf.setImage(
            with: URL(string: presenter.getImagesListService().photos[indexPath.row].thumbImageURL),
            placeholder: imagePlaceHolder,
            options: []
        ) { [weak self] _ in
            guard let self else { return }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        cell.dataLabel.text = DateFormatter.dateFormatter.string(
            from: presenter.getImagesListService().photos[indexPath.row].createdAt ?? Date()
        )
        let isLiked = presenter.getImagesListService().photos[indexPath.row].isLiked
        let likeImage = isLiked ? UIImage(named: Constants.activeImage) : UIImage(named: Constants.noActiveImage)
        cell.likeButton.setImage(likeImage, for: .normal)
        cell.backgroundGradientView.addGradient(colors: [.clear, .ypBlack, .ypBlack, .clear])
    }
}
// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        presenter.getPhotos().count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        imageListCell.delegate = self
        return imageListCell
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        let testMode = ProcessInfo().arguments.contains("testMode")
        if (!testMode && indexPath.row == tableView.numberOfRows(inSection: 0) - 1) {
            presenter.fetchPhotosNextPage()
        }
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        presenter.getPhotos()[indexPath.row].size.height * view.frame.width / presenter.getPhotos()[indexPath.row].size.width
    }
}
// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = presenter.getPhotos()[indexPath.row]
        
        UIBlockingProgressHUD.show()
        presenter.getImagesListService().changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.presenter.setPhotos(self.presenter.getImagesListService().photos)
                cell.setIsLiked(self.presenter.getPhotos()[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                let alert = UIAlertController(
                    title: "Что-то пошло не так",
                    message: "Не удалось войти в систему",
                    preferredStyle: .alert
                )
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    alert.dismiss(animated: true)
                }
                alert.addAction(okAction)
                self.present(alert, animated: true)
            }
        }
    }
}

extension DateFormatter {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.dateFormat = "d MMMM yyyy"
        formatter.timeStyle = .none
        return formatter
    }()
}
