//
//  Lif3ViewModel.swift
//  Lif3Wallet
//
//  Created by Vanila Tech Bibhut on 2/24/23.
//

import UIKit
import Foundation
import Alamofire

struct Lif3ViewModel: Codable {
    func getLif3NewsList(completion: @escaping ([Lif3NewsListModel]?) -> Void) {
        
        let lif3NewsUrl = "https://assets.lif3.com/wallet/lif3-news/lif3news.json"
           Alamofire.request(lif3NewsUrl, method: .get, encoding: URLEncoding.default).responseJSON
           { response in
               guard let data = response.data else { return }
               do {
                   let decoder = JSONDecoder()
                   let lif3News = try decoder.decode(Lif3NewsModel.self, from: data)
                   let newsList = lif3News.news
                   completion(newsList)
               } catch let error {
                   print(error)
                   completion(nil)
               }
           }
       }
   
}
