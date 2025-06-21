//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Александр Клопков on 19.06.2025.
//

import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let largeImageURL: String
    let thumbImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Codable {
    let id: String
    let createdAt: String
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

struct UrlsResult: Codable {
    let full: URL
    let thumb: URL
    
    private enum CodingKeys: String, CodingKey {
        case full = "full"
        case thumb = "thumb"
    }
}

enum ImageListServiceError: Error {
    case invalidRequest
}

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private init() {}
    
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    
    private let token = OAuth2TokenStorage.shared.token
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    
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
        
        guard var lastLoadedPage else {
            lastLoadedPage = 1
            return
        }
        lastLoadedPage += 1
    }
    
    func makeImagesListRequest(with page: Int) -> URLRequest? {
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
        //let date = DateFormatter.dateFormatter.date(from: photoUnsplash.createdAt)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        let date = formatter.date(from: photoUnsplash.createdAt)
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
}
