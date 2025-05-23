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

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private init() {}
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = Constants.baseURL else {
            print("Unable to get base URL")
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
            print("Unable to get URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        return request
    }
    
    func fetchOAuthToken(code: String, handler: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Request error")
            return
        }
        
        let task = URLSession.shared.data(for: request, completion:  { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    do {
                        let authToken = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: success)
                        self.oauth2TokenStorage.token = authToken.accessToken
                        handler(.success(authToken.accessToken))
                    } catch {
                        print("Decoding error: \(error.localizedDescription)")
                        handler(.failure(error))
                    }
                case .failure(let error):
                    print("Network error: \(error.localizedDescription)")
                    handler(.failure(error))
                }
            }
        })
        task.resume()
    }
}
