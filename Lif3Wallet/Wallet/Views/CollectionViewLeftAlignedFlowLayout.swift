// Copyright © 2019 Stormbird PTE. LTD.

import Foundation
import UIKit

class CollectionViewLeftAlignedFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let originalAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        var updatedAttributes = originalAttributes
        for each in originalAttributes where each.representedElementKind == nil {
            guard let index = updatedAttributes.firstIndex(of: each) else { continue }
            layoutAttributesForItem(at: each.indexPath).flatMap { updatedAttributes[index] = $0 }
        }
        return updatedAttributes
    }
    // swiftlint:disable all
    //Force each item in every row, other than the first item in each row, to be place to the right of the previous item
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let currentItemAttributes = super.layoutAttributesForItem(at: indexPath) else { return nil }
        //First item in section is also first item in current row, so we can early return
        let isFirstItemInSection = indexPath.item == 0
        if isFirstItemInSection {
            currentItemAttributes.positionFrameX(x: sectionInset.left)
            return currentItemAttributes
        }

        guard let collectionView = collectionView else { return nil }
        guard let previousFrame = previousItemFrameOfItem(withIndexPath: indexPath) else { return currentItemAttributes }
        let previousFrameRightPoint = previousFrame.origin.x + previousFrame.width
        let currentFrame = currentItemAttributes.frame
        let collectionViewContentWidth = collectionView.frame.width - sectionInset.left - sectionInset.right
        let currentRowFrameInCollectionView = CGRect(x: sectionInset.left, y: currentFrame.origin.y, width: collectionViewContentWidth, height: currentFrame.size.height)
        let isFirstItemInRow = previousFrame.intersection(currentRowFrameInCollectionView).isEmpty

        if isFirstItemInRow {
            currentItemAttributes.positionFrameX(x: sectionInset.left)
            return currentItemAttributes
        }

        currentItemAttributes.positionFrameX(x: previousFrameRightPoint + minimumInteritemSpacing)
        return currentItemAttributes
    }
    // swiftlint:enable all

    private func previousItemFrameOfItem(withIndexPath indexPath: IndexPath) -> CGRect? {
        let previousIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
        guard let previousAttributes = layoutAttributesForItem(at: previousIndexPath) else { return nil }
        let previousFrame = previousAttributes.frame
        return previousFrame
    }
}

fileprivate extension UICollectionViewLayoutAttributes {
    func positionFrameX(x: CGFloat) {
        var frame = self.frame
        frame.origin.x = x
        self.frame = frame
    }
}


// NOTE: Doesn't work for horizontal layout!
class CenterAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        // Copy each item to prevent "UICollectionViewFlowLayout has cached frame mismatch" warning
        guard let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes] else { return nil }
        
        // Constants
        let leftPadding: CGFloat = 8
        let interItemSpacing = minimumInteritemSpacing
        
        // Tracking values
        var leftMargin: CGFloat = leftPadding // Modified to determine origin.x for each item
        var maxY: CGFloat = -1.0 // Modified to determine origin.y for each item
        var rowSizes: [[CGFloat]] = [] // Tracks the starting and ending x-values for the first and last item in the row
        var currentRow: Int = 0 // Tracks the current row
        attributes.forEach { layoutAttribute in
            
            // Each layoutAttribute represents its own item
            if layoutAttribute.frame.origin.y >= maxY {
                
                // This layoutAttribute represents the left-most item in the row
                leftMargin = leftPadding
                
                // Register its origin.x in rowSizes for use later
                if rowSizes.count == 0 {
                    // Add to first row
                    rowSizes = [[leftMargin, 0]]
                } else {
                    // Append a new row
                    rowSizes.append([leftMargin, 0])
                    currentRow += 1
                }
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + interItemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
            
            // Add right-most x value for last item in the row
            rowSizes[currentRow][1] = leftMargin - interItemSpacing
        }
        
        // At this point, all cells are left aligned
        // Reset tracking values and add extra left padding to center align entire row
        leftMargin = leftPadding
        maxY = -1.0
        currentRow = 0
        attributes.forEach { layoutAttribute in
            
            // Each layoutAttribute is its own item
            if layoutAttribute.frame.origin.y >= maxY {
                
                // This layoutAttribute represents the left-most item in the row
                leftMargin = leftPadding
                
                // Need to bump it up by an appended margin
                let rowWidth = rowSizes[currentRow][1] - rowSizes[currentRow][0] // last.x - first.x
                let appendedMargin = (collectionView!.frame.width - leftPadding  - rowWidth - leftPadding) / 2
                leftMargin += appendedMargin
                
                currentRow += 1
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + interItemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        
        return attributes
    }
}
