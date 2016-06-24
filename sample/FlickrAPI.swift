//
//  FlickerAPI.swift
//  photoRama
//
//  Created by macbook on 4/14/16.
//  Copyright © 2016 macbook. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

struct FlickrAPI {
    private static let baseURLString = "https://api.flickr.com/services/rest"
    private static let apiKey = "4cc71ede4a18054e47bdb7b714947f73"
    static var counter = 0
    private static let dateFormatter : NSDateFormatter = {
       let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df
    }()
    //MARK: Methods to construct and return URL
    static func recentPhotosURL() -> NSURL {
        return flickrURL(.RecentPhotos, parameters: ["extras" : "url_h,date_taken"])
    }
    
    private static func flickrURL(method : Method, parameters : [String : String]?) -> NSURL
    {
        let components = NSURLComponents(string: baseURLString)!
        var queryItem = [NSURLQueryItem]()
        let baseParams = [
            "method" : method.rawValue,
            "api_key": apiKey,
            "format" : "json",
            "nojsoncallback" : "1"
                        ]
        for (key, value) in baseParams{
            let item = NSURLQueryItem(name: key, value: value)
            queryItem.append(item)
        }
        
        if let additionalParams  = parameters{
            for (key,value) in additionalParams{
                let item = NSURLQueryItem(name: key, value: value)
                queryItem.append(item)
            }
        }
        
        components.queryItems = queryItem
        return components.URL!
    }
    
    //MARK: Methods to retrieve Photo type data from JSON Data
    static func photosFromJSONData(value : AnyObject, inContext context: NSManagedObjectContext) -> PhotosResult
    {
           var finalPhotos = [Photo]()
           let jsonObj = JSON(value)
           let photos  = jsonObj["photos"].dictionaryValue
           for photo in (photos["photo"]?.arrayValue)! {
                let photoID = String(photo["id"].intValue)
                //print("photoObj.photoID " + photo["id"].stringValue)
                let title = photo["title"].stringValue
                //print("photoObj.title " + photo["title"].stringValue)
                let dateString = photo["datetaken"].stringValue
                let datetaken = dateFormatter.dateFromString(dateString)!
                //print("photoObj.datetaken " + dateString)
                let tempURL = photo["url_h"].stringValue
                let remoteURL = NSURL(string: tempURL)!
                //print("photoObj.remoteURL" + tempURL)
                let width = photo["width_h"].intValue
                let height = photo["height_h"].intValue
            
            let fetchReq = NSFetchRequest(entityName: "Photo")
            fetchReq.predicate = NSPredicate(format: "photoID == \(photoID)", argumentArray: nil)
            var fetchedPhotos : [Photo]?
            context.performBlockAndWait { () -> Void in
                fetchedPhotos =  try! context.executeFetchRequest(fetchReq) as! [Photo]
            }
            if fetchedPhotos?.count > 0 {
                counter+=1
                finalPhotos.append((fetchedPhotos?.first)!)
            } else
            {
                if tempURL != "" {
                    var photo : Photo!
                    context.performBlockAndWait { () -> Void in
                        photo = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: context) as! Photo
                        photo.photoID = photoID
                        photo.title = title
                        photo.datetaken = datetaken
                        photo.remoteURL = remoteURL
                        photo.height = height
                        photo.width = width
                        
                        finalPhotos.append(photo)
                   }
                }
            }
        }
    return .Success(finalPhotos)
    }
    
        
        /*
        do{
            let jsonObj : AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                guard let jsonDict = jsonObj as? [NSObject:AnyObject],
                    let photos = jsonDict["photos"] as? [String : AnyObject],
                    let photosArray =  photos["photo"] as? [[String : AnyObject]]
                    else {
                        return .Failure(FlickrError.InvalidJSONData)
                }
                
                var finalPhotos = [Photo]()
                for photo in photosArray
                {
                    if let photoItem = photoFromPhotosArray(photo, inContext: context){
                    finalPhotos.append(photoItem)
                    }
                }
            return .Success(finalPhotos)
        }
        catch let jsonError {
            return .Failure(jsonError)
        } */
    
    /*private static func photoFromPhotosArray(photoObj : Photo, inContext context : NSManagedObjectContext) -> Photo?
    {
       
     /*   guard let photoID = photoObj["id"] as? String,
             let title = photoObj["title"] as? String,
             let dateString = photoObj["datetaken"] as? String,
             let datetaken = dateFormatter.dateFromString(dateString),
             let tempURL = photoObj["url_h"] as? String,
             let remoteURL = NSURL(string: tempURL)
        else {
                return nil
             } */
        let fetchReq = NSFetchRequest(entityName: "Photo")
        fetchReq.predicate = NSPredicate(format: "photoID == \(photoObj.photoID)", argumentArray: nil)
        var fetchedPhotos : [Photo]?
        context.performBlockAndWait { () -> Void in
            fetchedPhotos =  try! context.executeFetchRequest(fetchReq) as! [Photo]
        }
        if fetchedPhotos?.count > 0 {
            counter+=1
            return fetchedPhotos?.first
        }
        var photo : Photo!
        context.performBlockAndWait { () -> Void in
            photo = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: context) as! Photo
            photo = photoObj
        
        }
        
        return photo
        //return Photo(photoID: photoID, title: title, dateTaken: dateTaken, remoteURL: remoteURL)
    } */
}
//MARK: ENUMs declared for this API
enum Method: String {
    case RecentPhotos = "flickr.photos.getRecent"
}

enum PhotosResult {
    case Success([Photo])
    case Failure(ErrorType)
}

enum FlickrError : ErrorType{
    case InvalidJSONData
    case NotAJSONObj
}



