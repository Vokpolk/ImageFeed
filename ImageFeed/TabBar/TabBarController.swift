//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Александр Клопков on 09.06.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        imagesListViewController.configure(ImagesListPresenter(view: imagesListViewController))
        
        let profileViewController = ProfileViewController()
        profileViewController.configure(ProfilePresenter(view: profileViewController))
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
