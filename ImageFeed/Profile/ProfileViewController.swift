//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Александр Клопков on 29.04.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    private var avatarImageView: UIImageView!
    private var nameLabel: UILabel!
    private var loginNameLabel: UILabel!
    private var userDescriptionLabel: UILabel!
    
    private var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        view.backgroundColor = UIColor(named: "YP Black")
        initAvatarImageView()
        initNameLabel()
        initLoginNameLabel()
        initUserDescriptionLabel()
        initLogoutButton()
    }
    
    private func initAvatarImageView() {
        let profileImage = UIImage(named: "Photo")
        let avatarImageView = UIImageView(image: profileImage)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)
        avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        self.avatarImageView = avatarImageView
    }
    
    private func initNameLabel() {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = UIColor(named: "YP White")
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8).isActive = true
        self.nameLabel = label
    }
    
    private func initLoginNameLabel() {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.textColor = UIColor(named: "YP Gray")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        self.loginNameLabel = label
    }
    
    private func initUserDescriptionLabel() {
        let label = UILabel()
        label.text = "Hello, world!"
        label.textColor = UIColor(named: "YP White")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8).isActive = true
        self.userDescriptionLabel = label
    }
    
    private func initLogoutButton() {
        let logoutButton = UIButton.systemButton(
            with: UIImage(named: "Exit")!,
            target: self,
            action: #selector(Self.didLogoutButtonTap)
        )
        logoutButton.tintColor = UIColor(named: "YP Red")
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor).isActive = true
    }
    
    @objc private func didLogoutButtonTap(_ sender: UIButton) { }
}
