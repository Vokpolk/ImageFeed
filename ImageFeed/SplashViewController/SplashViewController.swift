//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Александр Клопков on 22.05.2025.
//
import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Private Properties
    private var logoImageView: UIImageView = {
        let logoImage = UIImage(named: "Logo_of_Unsplash")
        let logoImageView = UIImageView(image: logoImage)
        return logoImageView
    }()
    
    //private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let profileService = ProfileService.shared
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "YP Black")
        [logoImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        initLogoImageViewConstraint()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oauth2TokenStorage.token {
            print("APP: [SplashViewController] [viewDidAppear] Token is available, showing TabBarController")
            fetchProfile(token)
        } else {
            print("APP: [SplashViewController] [viewDidAppear] Token is'nt available, showing AuthenticationScreen")
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            guard let authViewController = storyboard.instantiateViewController(
                withIdentifier: "AuthViewController"
            ) as? AuthViewController else {
                print("APP: [SplashViewController] [viewDidAppear] can't convert UIViewController to AuthViewController")
                return
            }
            authViewController.delegate = self
            let navigationViewController = UINavigationController(
                rootViewController: authViewController
            )
            navigationViewController.modalPresentationStyle = .fullScreen
            present(navigationViewController, animated: true)
        }
    }
    
    // MARK: - Private Methods
    private func initLogoImageViewConstraint() {
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
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
                let alert = UIAlertController(title: "Что-то пошло не так",
                                              message: "Не удалось войти в систему",
                                              preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    alert.dismiss(animated: true)
                }
                alert.addAction(okAction)
                present(alert, animated: true)
                break
            }
        }
    }
}
