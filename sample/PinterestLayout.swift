//
//  PinterestLayout.swift
//  sample
//
//  Created by macbook on 6/22/16.
//  Copyright © 2016 macbook. All rights reserved.
//

import UIKit

protocol PinterestLayoutDelegate {
    func collectionView(collectionView : UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath, withWidth : CGFloat) -> CGFloat
}

class PinterestLayoutAttributes : UICollectionViewLayoutAttributes {
    var photoHeight : CGFloat = 0
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! PinterestLayoutAttributes
        copy.photoHeight = photoHeight
        return copy
    }
    override func isEqual(object: AnyObject?) -> Bool {
        if let attributes = object as? PinterestLayoutAttributes{
            if attributes.photoHeight == photoHeight {
                return super.isEqual(object)
            }
        }
        return false
    }
}

class PinterestLayout: UICollectionViewLayout {
    
    var delegate : PinterestLayoutDelegate!
    
    var numberOfColumns = 3
    var cellPadding : CGFloat = 4.0
    
    private var cache = [PinterestLayoutAttributes]()
    
    private var contentWidth : CGFloat {
        let insets = collectionView!.contentInset
        return CGRectGetWidth(collectionView!.bounds)/2 - (insets.left + insets.right)
    }
    
    private var contentHeight : CGFloat = 0

    override class func layoutAttributesClass() -> AnyClass {
        return PinterestLayoutAttributes.self
    }
    override func prepareLayout()
    {
        var columnWidth : CGFloat {
            return ceil(contentWidth/CGFloat(numberOfColumns))
        }
        var xOffsets = [CGFloat]()
        var yOffsets = [CGFloat](count: numberOfColumns, repeatedValue : 0)
        
        var currCol = 0
        
        if cache.isEmpty {
            for column in 0..<numberOfColumns {
                xOffsets.append(CGFloat(column) * columnWidth)
            }
        }
        
        for item in 0..<collectionView!.numberOfItemsInSection(0)
        {
            //print(item.description)
            let indexPath   = NSIndexPath(forItem: item, inSection: 0)
            let width       = columnWidth - cellPadding*2
            let photoheight = delegate.collectionView(collectionView!, heightForPhotoAtIndexPath:
                                 indexPath, withWidth: width)
            let height      = cellPadding + photoheight + cellPadding
            
            let frame       = CGRectMake(xOffsets[currCol], yOffsets[currCol], columnWidth, height)
            let insetFrame  = CGRectInset(frame, cellPadding, cellPadding)
            
            let attributes = PinterestLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.frame = insetFrame
            attributes.photoHeight = photoheight
            cache.append(attributes)
            
            yOffsets[currCol] = yOffsets[currCol] + height
            contentHeight = max(contentHeight, CGRectGetMaxY(frame))
            
            currCol = currCol >= (numberOfColumns - 1) ? 0 : (currCol + 1)
            
        }
        
    }
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if CGRectIntersectsRect(attributes.frame, rect) {
                layoutAttributes.append(attributes)
            }
        }
        
        return layoutAttributes
    }
    
    
    

}
