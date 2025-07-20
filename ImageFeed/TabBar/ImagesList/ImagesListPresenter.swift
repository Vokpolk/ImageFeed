//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Александр Клопков on 16.07.2025.
//

import Foundation

public protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func fetchPhotosNextPage()
    func updateTableViewAnimated() -> (newCount: Int, oldCount: Int)
    
    func getPhotos() -> [Photo]
    func setPhotos(_ photo: [Photo])
    
    func getImagesListService() -> ImagesListService
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    // MARK: - Public Properties
    weak var view: ImagesListViewControllerProtocol?
    
    // MARK: - Private Properties
    private var photos: [Photo] = []
    private var imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    
    init(view: ImagesListViewControllerProtocol) {
        self.view = view
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            _ = self.view?.updateTableViewAnimated()
        }
    }
    
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    func updateTableViewAnimated() -> (newCount: Int, oldCount: Int) {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        
        photos = imagesListService.photos
        return (newCount, oldCount)
    }
    
    func getPhotos() -> [Photo] {
        photos
    }
    
    func setPhotos(_ photos: [Photo]) {
        self.photos = photos
    }
    
    func getImagesListService() -> ImagesListService {
        imagesListService
    }
}
