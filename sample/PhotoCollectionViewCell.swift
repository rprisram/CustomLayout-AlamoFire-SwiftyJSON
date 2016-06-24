//
//  PhotoCollectionViewCell.swift
//  photoRama
//
//  Created by macbook on 4/15/16.
//  Copyright © 2016 macbook. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var spinner : UIActivityIndicatorView!
    @IBOutlet weak var imageHeightConstraint : NSLayoutConstraint!
    
    
    
    func updateWithImage(image :UIImage?)
    {
        if let img = image {
            spinner.stopAnimating()
            imageView.image = img
            
        } else
        {
            spinner.startAnimating()
            imageView.image = nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //imageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.autoresizingMask = [.FlexibleHeight,.FlexibleWidth]
        self.contentView.translatesAutoresizingMaskIntoConstraints = true
        updateWithImage(nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.contentView.autoresizingMask = [.FlexibleHeight,.FlexibleWidth]
        self.contentView.translatesAutoresizingMaskIntoConstraints = true
        updateWithImage(nil)
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        if let layoutAttributes = layoutAttributes as? PinterestLayoutAttributes{
            imageHeightConstraint.constant = layoutAttributes.photoHeight
        }
    }
}

extension NSLayoutConstraint{
    override public var description : String{
        let id = identifier ?? ""
        return "id is \(id) constant is \(constant)"
    }
}