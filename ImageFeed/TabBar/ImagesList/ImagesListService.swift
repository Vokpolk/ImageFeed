//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Александр Клопков on 19.06.2025.
//

import UIKit

private enum HTTPMethod: String {
    case post = "POST"
    case delete = "DELETE"
}

final class ImagesListService {
    
    // MARK: - Static Properties
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    // MARK: - Initializer
    private init() {}
    
    // MARK: - Public Properties
    var photos: [Photo] = []
    
    // MARK: - Private Properties
    private var lastLoadedPage: Int?
    
    let isoFormatter = ISO8601DateFormatter()
    let outputFormatter = DateFormatter()
    
    private let token = OAuth2TokenStorage.shared.token
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var changeLikeTask: URLSessionTask?
    
    // MARK: - fetchImagesList
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        if task != nil {
            task?.cancel()
        }
        // Здесь получим страницу номер 1, если не загружали ничего,
        // и следующую страницу (на единицу больше),
        // если есть предыдущая загруженная страница
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makeImagesListRequest(with: nextPage) else {
            print("APP: [ImageList] Request error")
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            switch result {
            case .success(let photosResult):
                guard let self else {
                    return
                }
                print("APP: [ImageList] SUCCESS: \(photosResult[0].images.full.absoluteString)")
                for photo in photosResult {
                    self.photos.append(self.makePhotoFromRequest(photo))
                }
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self
                )
            case .failure(let failure):
                print("APP: [ImageList] FAILURE: \(failure)")
            }
            self?.task = nil
        }
        
        self.task = task
        task.resume()
        
        if lastLoadedPage == nil {
            lastLoadedPage = 1
        } else {
            lastLoadedPage! += 1
        }
    }
    
    // MARK: - fetchLikeOrUnlikePhoto
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        if changeLikeTask != nil {
            changeLikeTask?.cancel()
        }
        guard let request = makeRequestLikeUnlikePhoto(id: photoId, isLike: isLike) else {
            print("APP: [ImageList] Request like/unlike error")
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<PhotoLikeResult, Error>) in
            switch result {
            case .success(let success):
                guard let self else {
                    return
                }
                print("APP: [ImageList] SUCCESS like/unlike: \(success.photoResult.id)")
                let isLiked = success.photoResult.isLiked
                self.updatePhotoLike(photoId, isLiked)
                completion(.success(Void()))
            case .failure(let failure):
                print("APP: [ImageList] FAILURE like/unlike: \(failure)")
                completion(.failure(failure))
            }
            self?.changeLikeTask = nil
        }
        self.changeLikeTask = task
        task.resume()
    }
    
    // MARK: - Requests
    private func makeImagesListRequest(with page: Int) -> URLRequest? {
        guard let apiURL = Constants.apiURL else {
            print("APP: [ImageList] Unable to get base URL")
            return nil
        }
        
        guard let url = URL(string: "/photos?page=\(page)", relativeTo: apiURL) else {
            print("APP: [ImageList] Unable to get photos image URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        guard let token else {
            print("APP: Unable to get Bearer Token")
            return nil
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    private func makePhotoFromRequest(_ photoUnsplash: PhotoResult) -> Photo {
        var date = Date()
        isoFormatter.formatOptions = [
            .withInternetDateTime,
            .withDashSeparatorInDate,
            .withColonSeparatorInTime
        ]
        if let photoDate = isoFormatter.date(from: photoUnsplash.createdAt ?? "") {
            outputFormatter.dateFormat = "d MMMM yyyy"
            
            let formattedDate = outputFormatter.string(from: photoDate)
            print("Date: " + formattedDate)
            date = photoDate
        } else {
            print("Date: Не удалось распознать дату")
        }
        return Photo(
            id: photoUnsplash.id,
            size: CGSize(width: photoUnsplash.width, height: photoUnsplash.height),
            createdAt: date,
            welcomeDescription: photoUnsplash.description ?? "",
            largeImageURL: photoUnsplash.images.full.absoluteString,
            thumbImageURL: photoUnsplash.images.thumb.absoluteString,
            isLiked: photoUnsplash.isLiked
        )
    }
    
    private func makeRequestLikeUnlikePhoto(id photoId: String, isLike: Bool) -> URLRequest? {
        guard let apiURL = Constants.apiURL else {
            print("APP: [ImageList] Unable to get base URL")
            return nil
        }
        
        guard let url = URL(
            string: "/photos"
            + "/\(photoId)"
            + "/like",
            relativeTo: apiURL
        ) else {
            print("APP: [ImageList] Unable to get like/unlike URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        guard let token else {
            print("APP: Unable to get Bearer Token")
            return nil
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        return request
    }
    
    // MARK: - Private Methods
    private func updatePhotoLike(_ id: String, _ isLiked: Bool) {
        if let index = self.photos.firstIndex(where: { $0.id == id }) {
            photos[index].isLiked = isLiked
            print("APP: [ImageList] [updatePhotoLike] isLiked: \(photos[index].isLiked)")
        }
    }
}
