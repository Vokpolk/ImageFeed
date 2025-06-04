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

final class ProfileImageService {
    static let shared = ProfileImageService()
    
    private init() {}
    
    private enum NetworkError: Error {
        case codeError
    }
    
    private(set) var avatarURL: String?
    
    private let token = OAuth2TokenStorage.shared.token
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastUsername: String?
    
    func fetchProfileImage(username: String, _ handler: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            if lastUsername != token {
                task?.cancel()
            } else {
                print("APP: ProfileServiceError.invalidRequest")
                handler(.failure(ProfileServiceError.invalidRequest))
                return
            }
        } else {
            if lastUsername == token {
                print("APP: ProfileServiceError.invalidRequest")
                handler(.failure(ProfileServiceError.invalidRequest))
                return
            }
        }
        lastUsername = token
        
        guard let request = makeProfileImageRequest(username: username) else {
            print("APP: Request error")
            handler(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.data(for: request, completion: { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    do {
                        let data = try JSONDecoder().decode(UserResult.self, from: success)
                        self?.avatarURL = data.profileImage.small.absoluteString
                        guard let avatar = self?.avatarURL else { return }
                        handler(.success(avatar))
                    } catch {
                        print("APP: Decoding error: \(error.localizedDescription)")
                        handler(.failure(error))
                    }
                case .failure(let error):
                    print("APP: Network error: \(error)")
                    handler(.failure(error))
                }
                self?.task = nil
                self?.lastUsername = nil
            }
        })
        self.task = task
        task.resume()
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
