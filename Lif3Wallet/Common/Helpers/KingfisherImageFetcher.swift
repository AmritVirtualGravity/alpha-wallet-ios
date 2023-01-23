//
//  KingfisherImageFetcher.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 09.09.2022.
//

import Foundation
import Kingfisher
import AlphaWalletFoundation
import PromiseKit
import SDWebImage

class KingfisherImageFetcher: ImageFetcher {
    
    struct AnyError: Error { }
    
    func retrieveImage(with url: URL) -> Promise<UIImage> {
        let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
        
        return Promise { seal in
            KingfisherManager.shared.retrieveImage(with: resource) { result in
                switch result {
                case .success(let response):
                    seal.fulfill(response.image)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func retrieveImageWithSdWebImage(with url: URL) -> Promise<UIImage> {
        let manager = SDWebImageManager.shared
        return Promise { seal in
            manager.loadImage(
                with: url,
                options: SDWebImageOptions.refreshCached,
                progress: nil,
                completed: { image, error, cacheType, finished, imageURL,argg  in
                    if let img = image  {
                        seal.fulfill(img)
                    } else {
                        seal.reject(AnyError())
                    }
                });
        }
    }
    
}

