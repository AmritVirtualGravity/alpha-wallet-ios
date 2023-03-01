//
//  Lif3ViewController+CollectionView.swift
//  Lif3Wallet
//
//  Created by Bibhut on 2/23/23.
//

import UIKit
import SDWebImage


extension Lif3ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return newsArr.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
 
            // Grab our cell from dequeueReusableCell, wtih the same identifier we set in our storyboard.
            let cell = collectionView.dequeReusableCell(withClass: BannerCell.self, for: indexPath)
            cell.loadCell(self.newsArr[indexPath.row])
             return cell
        }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: newsCollectionView.bounds.width - 20, height: newsCollectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let news = self.newsArr[indexPath.row]
        if let url = news.url {
            self.delegate?.didTapNews(url:url)
        }
    }
    
    
  
   
    func collectionViewSetup() {
        // Collection View Banner Configuration
        let bannerHeight = newsCollectionView.bounds.height
        let bannerWidth = newsCollectionView.bounds.width
        let layoutBanner: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layoutBanner.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right:0)
        layoutBanner.itemSize = CGSize(width: bannerWidth, height: bannerHeight)
        layoutBanner.minimumInteritemSpacing = 0
        layoutBanner.minimumLineSpacing = 16
        layoutBanner.scrollDirection = .horizontal
        newsCollectionView.isPagingEnabled = true
        newsCollectionView.collectionViewLayout = layoutBanner
    }
    
    
    func startBannerScroll() {
        if newsArr.count > 0 {
            // just in case you had existing `Timer`, `invalidate` it before we lose our reference to it
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
                
                self?.bannerScrollIndex += 1
                if (self?.bannerScrollIndex)! >= (self?.newsArr.count)! {
                    self?.bannerScrollIndex = 0
                }
                
                let indexPath = IndexPath(row: (self?.bannerScrollIndex)!, section: 0)
                
                self?.newsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    
    
    
}

