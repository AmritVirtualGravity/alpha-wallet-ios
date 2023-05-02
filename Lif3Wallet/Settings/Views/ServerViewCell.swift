// Copyright © 2018 Stormbird PTE. LTD.

import UIKit
//import SVGKit
import SDWebImage

class ServerTableViewCell: UITableViewCell {
    static let selectionAccessoryType: (selected: UITableViewCell.AccessoryType, unselected: UITableViewCell.AccessoryType) = (selected: .checkmark, unselected: .none)

    private let nameLabel = UILabel()
    
    private let priceChangeLabel = UILabel()
    
    private let serverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.contentMode = .center
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var topSeparator: UIView = UIView.spacer(backgroundColor: R.color.mike()!)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let stackView = [
            serverImageView,
            .spacerWidth(8),
            nameLabel,
            .spacer(),
            priceChangeLabel
        ].asStackView(axis: .horizontal, alignment: .center)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(topSeparator)
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            serverImageView.widthAnchor.constraint(equalToConstant: 20),
            serverImageView.heightAnchor.constraint(equalToConstant: self.bounds.height),
            topSeparator.topAnchor.constraint(equalTo: contentView.topAnchor),
            topSeparator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.anchorsConstraint(to: contentView, edgeInsets: .init(top: 0, left: DataEntry.Metric.sideMargin, bottom: 0, right: DataEntry.Metric.sideMargin)),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    func configure(viewModel: TokenListServerTableViewCellViewModel) {
        selectionStyle          = viewModel.selectionStyle
        backgroundColor         = viewModel.backgroundColor
        accessoryType           = viewModel.accessoryType
        topSeparator.isHidden   = viewModel.isTopSeparatorHidden
        nameLabel.textAlignment = .left
        nameLabel.font          = viewModel.serverFont
        nameLabel.textColor     = viewModel.serverColor
        nameLabel.text          = viewModel.serverName
        
        priceChangeLabel.textAlignment = .right
        priceChangeLabel.font          = viewModel.serverFont
        priceChangeLabel.textColor     = viewModel.serverColor
        priceChangeLabel.text          = viewModel.sum.rC.dollar
        
        serverImageView.sd_setImage(with: URL.getImageUrlFromChainId(viewModel.server.chainID), placeholderImage: GlobalConstants.secondaryPlaceHolderImage) { [weak serverImageView] image,_,_,_  in
            guard image == nil else { return }
            serverImageView?.sd_setImage(with: URL.getImageUrlFromChainIdAlternative(viewModel.server.chainID), placeholderImage: GlobalConstants.secondaryPlaceHolderImage)
        }
    }

    func returnServerImageUrl(chainId: String)  -> String{
    //        return "https://assets.lif3.com/wallet/chains/\(symbol)-Isolated.svg"
        return "https://assets.lif3.com/wallet/chains/\(chainId)-I.svg"
    }

  
}

// Swift 5
func verifyUrl (urlString: String?) -> Bool {
    if let urlString = urlString {
        if let url = NSURL(string: urlString) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
    }
    return false
}

func canOpenURL(string: String?) -> Bool {
    guard let urlString = string else {return false}
    guard let url = URL(string: urlString) else {return false}
    if !UIApplication.shared.canOpenURL(url) {return false}

    //
    let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
    let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
    return predicate.evaluate(with: string)
}
