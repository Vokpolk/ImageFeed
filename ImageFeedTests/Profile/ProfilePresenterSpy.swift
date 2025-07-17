//
//  ProfilePresenterSpy.swift
//  ImageFeed
//
//  Created by Александр Клопков on 16.07.2025.
//

import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: ProfileViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func updateAvatar() {
        
    }
    
    func profileLogout() {
        
    }
    
    
}
