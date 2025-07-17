//
//  ImagesListPresenterSpy.swift
//  ImageFeed
//
//  Created by Александр Клопков on 16.07.2025.
//

import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: ImagesListViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchPhotosNextPage() {
        
    }
    
    func updateTableViewAnimated() -> (newCount: Int, oldCount: Int) {
        (0, 10)
    }
    
    func getPhotos() -> [Photo] {
        let array: [Photo] = []
        return array
    }
    
    func setPhotos(_ photo: [Photo]) {
        
    }
    
    func getImagesListService() -> ImagesListService {
        ImagesListService.shared
    }
    

}
