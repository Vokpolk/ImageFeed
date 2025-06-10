//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Александр Клопков on 03.06.2025.
//

import UIKit

struct ProfileResponseBody: Codable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
    
    private enum CodingKeys: String, CodingKey {
        case username = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

enum ProfileServiceError: Error {
    case invalidRequest
}

final class ProfileService {
    static let shared = ProfileService()
    
    private init() {}
    
    private enum NetworkError: Error {
        case codeError
    }
    
    private(set) var profile: Profile?
    
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastToken: String?
    
    func fetchProfile(_ token: String, handler: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            if lastToken != token {
                task?.cancel()
            } else {
                print("APP: ProfileServiceError.invalidRequest")
                handler(.failure(ProfileServiceError.invalidRequest))
                return
            }
        } else {
            if lastToken == token {
                print("APP: ProfileServiceError.invalidRequest")
                handler(.failure(ProfileServiceError.invalidRequest))
                return
            }
        }
        lastToken = token
        
        guard let request = makeProfileRequest(token: token) else {
            print("APP: Request error")
            handler(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResponseBody, Error>) in
            switch result {
            case .success(let profileRespone):
                print("APP: SUCCESS profile: \(profileRespone.username)")
                let profile = Profile(
                    username: profileRespone.username,
                    name: "\(profileRespone.firstName)" +
                          " \(profileRespone.lastName ?? "")",
                    loginName: "@\(profileRespone.username)",
                    bio: profileRespone.bio
                )
                self?.profile = profile
                handler(.success(profile))
            case .failure(let failure):
                print("APP: FAILURE profile: \(failure.localizedDescription)")
                handler(.failure(failure))
            }
            self?.task = nil
            self?.lastToken = nil
        }
        
        self.task = task
        task.resume()
    }
    
    func makeProfileRequest(token: String) -> URLRequest? {
        guard let apiURL = Constants.apiURL else {
            print("APP: Unable to get base URL")
            return nil
        }
        
        guard let url = URL(string: "\(apiURL)" + "/me") else {
            print("APP: Unable to get profile URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
