//
//  PhotoStore.swift
//  photoRama
//
//  Created by macbook on 4/14/16.
//  Copyright © 2016 macbook. All rights reserved.
//

import UIKit
import CoreData
import Alamofire



class PhotoStore{
    let session : NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: config)
    }()
    //MARK: Core Data Stack Declaration
    let coreDataStack = CoreDataStack(modelName: "photoRama")
    
    //MARK: Image storage
    let imageStore = ImageStore()
    
    //MARK: Core Data Fetch request for all photos & Tags
    func fetchMainQueuePhotos(predicate : NSPredicate? = nil, sortDescriptors : [NSSortDescriptor]? = nil) throws -> [Photo]
    {
            let fetchReq = NSFetchRequest(entityName: "Photo")
            fetchReq.predicate = predicate
            fetchReq.sortDescriptors = sortDescriptors
            let context = self.coreDataStack.mainQueueContext
            var mainQueuePhotos :[Photo]?
            var fetchReqErr : ErrorType?
            context.performBlockAndWait { () -> Void in
                do {
                        mainQueuePhotos = try context.executeFetchRequest(fetchReq) as? [Photo]
                   }
                catch let err{
                    fetchReqErr = err
                }
            }
            guard let photos = mainQueuePhotos else
            {
                    throw fetchReqErr!
            }
        
        return photos
    }
    
    func fetchMainQueueTags(predicate : NSPredicate? = nil,sortDescriptors : [NSSortDescriptor]? = nil)
        throws -> [NSManagedObject] {
            let fetchReq = NSFetchRequest(entityName: "Tag")
            fetchReq.predicate = predicate
            fetchReq.sortDescriptors = sortDescriptors
            let context = self.coreDataStack.mainQueueContext
            var fetchErr : ErrorType?
            var mainQueuetags :[NSManagedObject]?
            context.performBlockAndWait({ () -> Void in
                do {
                    mainQueuetags = try context.executeFetchRequest(fetchReq) as? [NSManagedObject]
                   }
                catch let error{
                    fetchErr = error
                    }
            })
                guard let tags = mainQueuetags else {
                    throw fetchErr!
                }
        return tags
    }
    
    
    //MARK: Fetch Photos and associated JSON data retrieval call
  /*  func fetchRecentPhotos(completion : (PhotosResult) -> Void){
        let url = FlickrAPI.recentPhotosURL()
        let req = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(req) { (data, response, error) -> Void in
        var result = self.processRecentPhotosRequest(data, error: error,inContext: self.coreDataStack.privateQueueContext)

            if case .Success(let photos) = result{
                do
                {
                    let context = self.coreDataStack.privateQueueContext
                    
                    context.performBlockAndWait({ () -> Void in
                    try! context.obtainPermanentIDsForObjects(photos)
                    })
                    
                    let objIDs = photos.map({ $0.objectID })
                    let predicate = NSPredicate(format: "self IN %@", objIDs) //  (format: "self IN %@",objIDs)
                    let sortByDateTaken = NSSortDescriptor(key: "datetaken", ascending: true)
                    
                    try self.coreDataStack.saveChanges()
                    let mainQueuePhotos = try! self.fetchMainQueuePhotos(predicate, sortDescriptors: [sortByDateTaken])
                    result = .Success(mainQueuePhotos)
                }
                catch let Error
                {
                    result = .Failure(Error)
                }
            }
        completion(result)
        }
        task.resume()
    } */
    
    func fetchRecentPhotos(completion : (PhotosResult) -> Void){
        let url = FlickrAPI.recentPhotosURL()
        let req = NSURLRequest(URL: url)
        Alamofire.request(req)
                 .responseJSON { (response) in
                    var result = self.processRecentPhotosRequest(response.result.value, error: response.result.error,inContext: self.coreDataStack.privateQueueContext)
                    
                    if case .Success(let photos) = result{
                        do
                        {
                            let context = self.coreDataStack.privateQueueContext
                            
                            context.performBlockAndWait({ () -> Void in
                                try! context.obtainPermanentIDsForObjects(photos)
                            })
                            
                            let objIDs = photos.map({ $0.objectID })
                            let predicate = NSPredicate(format: "self IN %@", objIDs) //  (format: "self IN %@",objIDs)
                            let sortByDateTaken = NSSortDescriptor(key: "datetaken", ascending: true)
                            
                            try self.coreDataStack.saveChanges()
                            let mainQueuePhotos = try! self.fetchMainQueuePhotos(predicate, sortDescriptors: [sortByDateTaken])
                            result = .Success(mainQueuePhotos)
                        }
                        catch let Error
                        {
                            result = .Failure(Error)
                        }
                    }
                    completion(result) 
        }
    
    }
    
    func processRecentPhotosRequest(value : AnyObject?, error : NSError?,inContext context: NSManagedObjectContext) -> PhotosResult {
        
        guard let jsonData = value else {
            return PhotosResult.Failure(error!)
        }
        return FlickrAPI.photosFromJSONData(jsonData, inContext: context)
    }
    
    //MARK: Fetch one image adn store in file
    func fetchImageForPhoto(photo : Photo, Completion : (ImageResult)-> Void)
    {
        //if its already downloaded, dont download again!
        let photoKey = photo.photoKey
        if let img = self.imageStore.retrieveImage(photoKey) {
            photo.image = img
            Completion(.Success(img))
            return
        }
        let url = photo.remoteURL
        let request = NSURLRequest(URL: url)
        Alamofire.request(request)
                 .response { (req, response, data, error) in
                    let result = self.processImageRequest(data, error: error)
                    if case let .Success(img) = result {
                        photo.image = img
                        self.imageStore.setImage(img, Key: photoKey)
                    }
                    Completion(result)
                 }
//                 .responseImage { (response) in
//                    if let img = response.result.value{
//                        print("image conversion successful")
//                        photo.image = img
//                        //self.imageStore.setImage(img, Key: photoKey)
//                        result = .Success(img)
//                    }
//                    if let _ = response.result.error {
//                        print("image conversion failure")
//                        result = .Failure(ImageError.ImageCreationError)
//                    }
//                }
//        if let result = result {Completion(result)}
//    }
    }
    
    func processImageRequest(data : NSData?, error : NSError?) -> ImageResult
    {
        guard let imageData = data,
              let image = UIImage(data: imageData)
            else {
                   return .Failure(ImageError.ImageCreationError)
                 }
        return .Success(image)
    }
    
}

//MARK: Enums for Image creation Handling
enum ImageResult {
    case Success(UIImage)
    case Failure(ErrorType)
}

enum ImageError : ErrorType{
    case ImageCreationError
}
