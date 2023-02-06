//
//  ContactListTableViewCell.swift
//  Lif3Wallet
//
//  Created by Vanila Tech Bibhut on 2/2/23.
//

import UIKit

class ContactListTableViewCell: UITableViewCell {

    @IBOutlet weak var contactImageView: UIImageView!
    
    @IBOutlet weak var contactNameLabel: UILabel!
    
    @IBOutlet weak var contactAddressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
