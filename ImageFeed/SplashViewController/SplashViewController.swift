//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Александр Клопков on 22.05.2025.
//
import UIKit
//import ProgressHUD

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let profileService = ProfileService.shared
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oauth2TokenStorage.token {
            print("APP: Token is available, showing TabBarController")
            fetchProfile(token)
            //switchToTabBarController()
        } else {
            print("APP: Token is'nt available, showing AuthenticationScreen")
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    private func switchToTabBarController() {
        //получаем экземпляр 'window' приложения
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        //создаем экземпляр нужного контроллера
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "TabBarViewController")
        
        //установим в 'rootViewController' полученный контроллер
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            fetchOAuthToken(code)
            
            guard let token = oauth2TokenStorage.token else { return }
            fetchProfile(token)
        }
    }
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            
            UIBlockingProgressHUD.dismiss()
            print("APP: UI unlocked")
            
            switch result {
            case .success(let token):
                self.fetchProfile(token)
            case .failure:
                // TODO: [Sprint 11]
                let alert = UIAlertController(title: "Что-то пошло не так",
                                              message: "Не удалось войти в систему",
                                              preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    alert.dismiss(animated: true)
                }
                alert.addAction(okAction)
                present(alert, animated: true)
            }
        }
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { result in
                    switch result {
                    case .success(let smallImage):
                        print("APP: smallImage: \(smallImage)")
                    case .failure:
                        print("APP: URLSession of Profile failed")
                        break
                    }
                }
                self.switchToTabBarController()
            case .failure:
                print("APP: URLSession of Profile failed")
                // TODO: [Sprint 11] Покажите ошибку получения профиля
                break
            }
        }
    }
}
