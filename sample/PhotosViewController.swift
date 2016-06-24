//
//  PhotosViewController.swift
//  photoRama
//
//  Created by macbook on 4/14/16.
//  Copyright © 2016 macbook. All rights reserved.
//

import UIKit
import AVFoundation

class PhotosViewController: UIViewController,UICollectionViewDelegate {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    var photoStore : PhotoStore!
    let photoDataSource = PhotoDataSource()
    weak var image : UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        if let layout = collectionView.collectionViewLayout as? PinterestLayout
        {
            layout.delegate = self
        }
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        if let patternImage = UIImage(named: "pattern") {
            view.backgroundColor = UIColor(patternImage: patternImage)
        }
        
        photoStore.fetchRecentPhotos(){result in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                switch result
                {
                case let .Success(photos) :
                    print("this current count - \(photos.count)")
                    let sortByDateTaken = NSSortDescriptor(key: "datetaken", ascending: true)
                    let allPhotos = try! self.photoStore.fetchMainQueuePhotos(nil, sortDescriptors: [sortByDateTaken])
                    print("whole count - \(allPhotos.count)")
                    print("Duplicate present - \(FlickrAPI.counter)")
                    self.photoDataSource.photos = allPhotos
                case let .Failure(error) :
                    self.photoDataSource.photos.removeAll()
                    print(" Errors fetching the photos \(error)")
                }
                self.collectionView.reloadData()
            })
            
        }
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
       let photo = photoDataSource.photos[indexPath.row]
        photoStore.fetchImageForPhoto(photo) { (result) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                let photoIndex = self.photoDataSource.photos.indexOf(photo)!
                let photoIndexPath = NSIndexPath(forRow: photoIndex, inSection: 0)
                if let photoCell = self.collectionView.cellForItemAtIndexPath(photoIndexPath) as? PhotoCollectionViewCell{
                    self.image = photo.image
                    photoCell.updateWithImage(photo.image)
                  }
                
                
            })
        }
       
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showItem"{
            let photoInfoViewController = segue.destinationViewController as! PhotoInfoViewController
            photoInfoViewController.photoStore = self.photoStore
            let photoIndexPath = collectionView.indexPathsForSelectedItems()?.first!
            let photoSelected = photoDataSource.photos[photoIndexPath!.row]
            photoInfoViewController.photo = photoSelected
            
        }
    }
}

extension PhotosViewController : PinterestLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath, withWidth: CGFloat) -> CGFloat {
        let width = withWidth
        let photoHeight = Int(photoDataSource.photos[indexPath.row].height)
        let photoWidth = Int(photoDataSource.photos[indexPath.row].width)
        let boundingRect = CGRectMake(0, 0, width, CGFloat(MAXFLOAT))
        let rect = AVMakeRectWithAspectRatioInsideRect(CGSize(width: photoWidth, height: photoHeight), boundingRect)
        return rect.size.height
    }
}