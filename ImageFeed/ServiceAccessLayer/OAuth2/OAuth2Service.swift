//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Александр Клопков on 22.05.2025.
//
import UIKit

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope = "scope"
        case createdAt = "created_at"
    }
}

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    
    func fetchOAuthToken(
        code: String,
        handler: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        checkLastCodeEnable(code: code, handler: handler)
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("APP: Request error")
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result:Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let success):
                print("APP: SUCCES accesToken: \(success.accessToken)")
                self?.oauth2TokenStorage.token = success.accessToken
                handler(.success(success.accessToken))
            case .failure(let failure):
                print("APP: FAILURE accesToken: \(failure.localizedDescription)")
                handler(.failure(failure))
            }
            self?.task = nil
            self?.lastCode = nil
        }
        
        self.task = task
        task.resume()
    }
    
    func checkLastCodeEnable(
        code: String,
        handler: @escaping (Result<String, Error>) -> Void
    ) {
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                handler(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                handler(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
    }
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = Constants.baseURL else {
            print("APP: Unable to get base URL")
            return nil
        }
        
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        ) else {
            print("APP: Unable to get URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        return request
    }
}
