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
        let urlServer = returnServerImageUrl(chainId: "\(viewModel.server.chainID)")
        let urlChain =  URL(string: "https://assets.lif3.com/wallet/chains/\(viewModel.server.chainID)-I.svg")
        
        
        let imageName = "icons-tokens-a-lend"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        
        self.serverImageView.sd_setImage(with: URL(string: urlServer) , placeholderImage: GlobalConstants.secondaryPlaceHolderImage)
        
//        if canOpenURL(string: urlServer) {
//            self.serverImageView.sd_setImage(with: URL(string: urlServer))
//        } else {
////            self.serverImageView.sd_setImage(with: urlChain)
//            self.serverImageView.sd_setImage(with: urlChain)
//        }
//        if let imageUrl = URL(string: url) {
//            self.serverImageView.sd_setImage(with: imageUrl)
////        self.serverImageView.sd_setImage(with: URL(named: url), placeholderImage: GlobalConstants.secondaryPlaceHolderImage))
//        } else {
//            self.serverImageView.sd_setImage(with: URL(string: "https://assets.lif3.com/wallet/chains/\(viewModel.server.chainID)-I.svg"))
//        }
        
//
//        if let imageUrl = URL(string: url) {
//            if let image = SVGKImage(contentsOf: imageUrl) {
//                 if let uiImageInstance = image.uiImage {
//                     self.serverImageView.image = uiImageInstance
//                 }
//              }
//        }
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
