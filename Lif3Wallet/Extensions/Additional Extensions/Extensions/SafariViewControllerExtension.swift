//
//  SafariViewControllerExtension.swift
//  DoCo22
//
//  Created by bibek timalsina on 9/24/20.
//  Copyright © 2020 ekbana. All rights reserved.
//

import SafariServices
import UIKit

extension UIViewController {
    func openInSafariViewController(urlString: String) {
        if let url = URL(string: urlString) {
            let safariViewController = SFSafariViewController(url: url)
            self.presentFullScreen(safariViewController, animated: true)
        }
    }
}
