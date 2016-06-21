//
//  PhotoMemoryRepository.swift
//  Vandelay
//
//  Created by Daniel Saidi on 2016-06-21.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Vandelay

class PhotoMemoryRepository : NSObject, PhotoRepository {
    
    
    // MARK: Properties
    
    private var photos = [String : Photo]()
    
    
    // MARK: Public functions
    
    func addPhoto(photo: Photo) {
        photos[photo.id] = photo
    }
    
    func deletePhoto(photo: Photo) {
        photos.removeValueForKey(photo.id)
    }
    
    func getPhotos() -> [Photo] {
        return photos.values.sort({ photo1, photo2 -> Bool in
            photo1.id < photo2.id
        })
    }
    
    func getPhoto(id: String) -> Photo? {
        return photos[id]
    }
}