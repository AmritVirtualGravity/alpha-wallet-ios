//
//  Lif3NewsCollectionViewCell.swift
//  Lif3Wallet
//
//  Created by Vanila Tech Bibhut on 2/23/23.
//

import UIKit

class Lif3NewsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var newsImageView: UIImageView! {
        didSet {
            newsImageView.contentMode = .scaleToFill
            newsImageView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var newsSubtitleLabel: UILabel!

}
