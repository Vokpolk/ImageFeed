//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Александр Клопков on 29.04.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    private var avatarImageView: UIImageView = {
        let profileImage = UIImage(named: "Photo")
        let avatarImageView = UIImageView(image: profileImage)
        return avatarImageView
    }()
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = UIColor(named: "YP White")
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        return label
    }()
    private var loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.textColor = UIColor(named: "YP Gray")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    private var userDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.textColor = UIColor(named: "YP White")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    private lazy var logoutButton: UIButton = {
        let logoutButton = UIButton.systemButton(
            with: UIImage(named: "Exit")!,
            target: nil,
            action: nil
        )
        logoutButton.addTarget(self, action: #selector(Self.didLogoutButtonTap), for: .touchUpInside)
        logoutButton.tintColor = UIColor(named: "YP Red")
        return logoutButton
    }()
    
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private var profile = ProfileService.shared
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP Black")
        
        [avatarImageView, nameLabel, loginNameLabel, userDescriptionLabel, logoutButton]
            .forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        initAvatarImageViewConstraint()
        initNameLabelConstraint()
        initLoginNameLabelConstraint()
        initUserDescriptionLabelConstraint()
        initLogoutButtonConstraint()
        
        guard let profile = profile.profile else { return }
        updateProfileDetails(profile: profile)
        /*ProfileImageService.shared.fetchProfileImage(username: profile.username) { result in
           switch result {
           case .success(let smallImage):
               print("APP: \(smallImage)")
           case .failure:
               print("APP: URLSession of Profile failed")
               break
           }
       }*/
        
        /*if let token = oauth2TokenStorage.token {
            ProfileService.shared.fetchProfile(token) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let profile):
                    setBaseProfileInformation(with: profile)
                case .failure:
                    print("APP: URLSession of Profile failed")
                    break
                }
            }
        }*/
    }
    
    // MARK: - Private Methods
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        userDescriptionLabel.text = profile.bio ?? ""
    }
    
    private func initAvatarImageViewConstraint() {
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
        ])
    }
    
    private func initNameLabelConstraint() {
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8)
        ])
    }
    
    private func initLoginNameLabelConstraint() {
        NSLayoutConstraint.activate([
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func initUserDescriptionLabelConstraint() {
        NSLayoutConstraint.activate([
            userDescriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor),
            userDescriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            userDescriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func initLogoutButtonConstraint() {
        NSLayoutConstraint.activate([
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }
    
    @objc private func didLogoutButtonTap(_ sender: UIButton) {
        print("APP: Tapped")
    }
}
