//
//  PhotoDataSource.swift
//  photoRama
//
//  Created by macbook on 4/15/16.
//  Copyright © 2016 macbook. All rights reserved.
//

import UIKit

class PhotoDataSource : NSObject, UICollectionViewDataSource {
    
    var photos  = [Photo]()
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UICollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        let photoImg = photos[indexPath.row]
        
        cell.updateWithImage(photoImg.image)
        return cell
    }
}
