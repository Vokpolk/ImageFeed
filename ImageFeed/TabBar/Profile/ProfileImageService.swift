//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Александр Клопков on 04.06.2025.
//

import UIKit

struct UserResult: Codable {
    let profileImage: ImagesSize
    
    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ImagesSize: Codable {
    let small: URL
    let medium: URL
    let large: URL
    
    private enum CodingKeys: String, CodingKey {
        case small = "small"
        case medium = "medium"
        case large = "large"
    }
}

enum ProfileImageServiceError: Error {
    case invalidRequest
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    private init() {}
    
    private enum NetworkError: Error {
        case codeError
    }
    
    private(set) var avatarURL: String?
    
    private let token = OAuth2TokenStorage.shared.token
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastUsername: String?
    
    func fetchProfileImageURL(username: String, _ handler: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        checkLastUsernameEnable(username, handler: handler)
        lastUsername = username
        
        guard let request = makeProfileImageRequest(username: username) else {
            print("APP: Request error")
            handler(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let success):
                print("APP: SUCCESS profileImage: \(success.profileImage.large.absoluteString)")
                self?.avatarURL = success.profileImage.large.absoluteString
                guard let avatar = self?.avatarURL else { return }
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": avatar]
                )
                handler(.success(avatar))
                //handler(.success(success.profileImage.small.absoluteString))
            case .failure(let failure):
                print("APP: FAILURE profileImage: \(failure.localizedDescription)")
                handler(.failure(failure))
            }
            self?.task = nil
            self?.lastUsername = nil
        }
        
        self.task = task
        task.resume()
        
        guard let profileImageUrl = avatarURL else { return }
        NotificationCenter.default.post(
            name: ProfileImageService.didChangeNotification,
            object: self,
            userInfo: ["URL": profileImageUrl]
        )
    }
    
    func checkLastUsernameEnable(
        _ username: String,
        handler: @escaping (Result<String, Error>) -> Void
    ) {
        if task != nil {
            if lastUsername != username {
                task?.cancel()
            } else {
                print("APP: ProfileImageServiceError.invalidRequest")
                handler(.failure(ProfileImageServiceError.invalidRequest))
                return
            }
        } else {
            if lastUsername == username {
                print("APP: ProfileImageServiceError.invalidRequest")
                handler(.failure(ProfileImageServiceError.invalidRequest))
                return
            }
        }
    }
    
    func makeProfileImageRequest(username: String) -> URLRequest? {
        guard let apiURL = Constants.apiURL else {
            print("APP: Unable to get base URL")
            return nil
        }
        
        guard let url = URL(
            string: "/users/\(username)",
            relativeTo: apiURL
        ) else {
            print("APP: Unable to get profile image URL")
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
}
