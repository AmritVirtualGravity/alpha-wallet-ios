//
//  Lif3ViewController.swift
//  Lif3Wallet
//
//  Created by Vanila Tech Bibhut on 1/16/23.
//

import UIKit

protocol lifeViewControllerDelegate {
     func didTapSwapTokens()
    func didTapFarm()
    func didTapNursery()
    func didTapFountain()
    func didTapLeverage()
    func didTapSingleStake()
    func didTapLif3Trade()
    func didTapNews(url: String)
}

class Lif3ViewController: UIViewController {
    
    // MARK: - Contants
    static func instantiate() -> Lif3ViewController {
        let controllerStr = String(describing: Lif3ViewController.self)
        return UIStoryboard(name: "Lif3", bundle: nil).instantiateViewController(withIdentifier: controllerStr) as! Lif3ViewController
    }

    var newsArr: [Lif3NewsListModel] = [Lif3NewsListModel]()
    
    weak var timer: Timer?
    
    
    var bannerScrollIndex = 0 
 
   let viewModel = Lif3ViewModel()
    @IBOutlet weak var newsCollectionView: UICollectionView!{
        didSet{
            self.newsCollectionView.productPromotionBannerStyle()
            self.newsCollectionView.dataSource = self
            self.newsCollectionView.delegate = self
        }
    }
    
    @IBOutlet weak var lif3TradeView: UIView! {
        didSet {
            lif3TradeView.layer.cornerRadius = 10
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapLif3Trade(_:)))
            lif3TradeView.addGestureRecognizer(tap)
        }
    }
    
    
    @IBOutlet weak var swapTokenView: UIView! {
        didSet {
            swapTokenView.layer.cornerRadius = 10
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapSwapToken(_:)))
            swapTokenView.addGestureRecognizer(tap)
        }
    }
    
    
    @IBOutlet weak var farmView: UIView!{
        didSet {
            farmView.layer.cornerRadius = 10
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapFarm(_:)))
            farmView.addGestureRecognizer(tap)
        }
    }
    
    
    @IBOutlet weak var nurseryView: UIView! {
        didSet {
            nurseryView.layer.cornerRadius = 10
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapNursery(_:)))
            nurseryView.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var fountainView: UIView! {
        didSet {
            fountainView.layer.cornerRadius = 10
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapFountain(_:)))
            fountainView.addGestureRecognizer(tap)
        }
    }
    
    
    
    
    @IBOutlet weak var leverageView: UIView! {
        didSet {
            leverageView.layer.cornerRadius = 10
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapLeverage(_:)))
            leverageView.addGestureRecognizer(tap)
        }
    }
    
    
    @IBOutlet weak var singleStakeView: UIView!{
        didSet {
            singleStakeView.layer.cornerRadius = 10
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapSingleStake(_:)))
            singleStakeView.addGestureRecognizer(tap)
        }
    }
    
    var delegate:lifeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionViewSetup()
        getLif3NewsListData()
        // Do any additional setup after loading the view.
    }

    @objc func tapSwapToken(_ sender: UITapGestureRecognizer? = nil) {
        delegate?.didTapSwapTokens()
    }
    
    @objc func tapFarm(_ sender: UITapGestureRecognizer? = nil) {
        delegate?.didTapFarm()
    }
    
    @objc func tapFountain(_ sender: UITapGestureRecognizer? = nil) {
        delegate?.didTapFountain()
    }
    
    @objc func tapLeverage(_ sender: UITapGestureRecognizer? = nil) {
        delegate?.didTapLeverage()
    }
    
    @objc func tapSingleStake(_ sender: UITapGestureRecognizer? = nil) {
        delegate?.didTapSingleStake()
    }
    
    @objc func tapNursery(_ sender: UITapGestureRecognizer? = nil) {
        delegate?.didTapNursery()
    }
    
    @objc func tapLif3Trade(_ sender: UITapGestureRecognizer? = nil) {
        delegate?.didTapLif3Trade()
    }
    

}

//Network Calls
extension Lif3ViewController {
    func getLif3NewsListData () {
        viewModel.getLif3NewsList{ newsList in
            self.newsArr  = newsList ?? []
            self.startBannerScroll()
            self.newsCollectionView.reloadData()
           
        }
    }
}


extension UICollectionView {
    func productPromotionBannerStyle() {
        self.register(cellType: BannerCell.self)
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
    }
}
