//
//  Lif3WebViewController.swift
//  Lif3Wallet
//
//  Created by Bibhut on 12/27/22.
//

import UIKit
import WebKit

class Lif3WebViewController: UIViewController {
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    // MARK: - Contants
    static func instantiate() -> Lif3WebViewController {
        let controllerStr = String(describing: Lif3WebViewController.self)
        return UIStoryboard(name: "Lif3", bundle: nil).instantiateViewController(withIdentifier: controllerStr) as! Lif3WebViewController
    }

    @IBOutlet weak var webView: WKWebView!{
        didSet{
            let link = URL(string:"https://www.lif3.com")!
            let request = URLRequest(url: link)
            webView.navigationDelegate = self
            webView.isOpaque = false
            webView.load(request)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.startAnimating()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
       super.viewWillLayoutSubviews();
        webView.scrollView.contentInset = .zero
        
    }
}


extension Lif3WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
     }
}
