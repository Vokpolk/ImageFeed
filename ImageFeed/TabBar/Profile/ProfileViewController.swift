//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Александр Клопков on 29.04.2025.
//

import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    //var presenter: ProfilePresenterProtocol? { get set }
    func configure(_ presenter: ProfilePresenterProtocol)
    func updateAvatar(url: URL)
    func updateProfileDetails(profile: Profile)
    func makeViewsInits()
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    // MARK: - Public Properties
    private var presenter: ProfilePresenterProtocol!
         
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    // MARK: - Private Properties
    private var avatarImageView: UIImageView = {
        let profileImage = UIImage(named: "User")
        let avatarImageView = UIImageView(image: profileImage)
        avatarImageView.layer.cornerRadius = 35
        avatarImageView.layer.masksToBounds = true
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
    private let profileLogout = ProfileLogoutService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        //presenter = ProfilePresenter(view: self)
        presenter?.viewDidLoad()
    }
    
    // MARK: - Public Methods
    func updateAvatar(url: URL) {
        let processor = RoundCornerImageProcessor(cornerRadius: 64)
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "User"),
            options: [ .processor(processor)]
        )
    }
    
    func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        userDescriptionLabel.text = profile.bio ?? ""
    }
    
    func makeViewsInits() {
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
    }
    
    @objc func didLogoutButtonTap() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self else { return }
            presenter?.profileLogout()
            alert.dismiss(animated: true)
        }
        let noAction = UIAlertAction(title: "Нет", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true)
    }
    
    // MARK: - Private Methods
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
}
