// Copyright © 2018 Stormbird PTE. LTD.

import UIKit
import SVGKit

class ServerTableViewCell: UITableViewCell {
    static let selectionAccessoryType: (selected: UITableViewCell.AccessoryType, unselected: UITableViewCell.AccessoryType) = (selected: .checkmark, unselected: .none)

    private let nameLabel = UILabel()
    
    private let serverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        return imageView
    }()
    private lazy var topSeparator: UIView = UIView.spacer(backgroundColor: R.color.mike()!)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let stackView = [
            serverImageView,
            .spacerWidth(8),
            nameLabel,
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
            stackView.anchorsConstraint(to: contentView, edgeInsets: .init(top: 0, left: StyleLayout.sideMargin, bottom: 0, right: StyleLayout.sideMargin)),
          
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    func configure(viewModel: ServerTableViewCellViewModelType) {
        selectionStyle = viewModel.selectionStyle
        backgroundColor = viewModel.backgroundColor
        accessoryType = viewModel.accessoryType
        topSeparator.isHidden = viewModel.isTopSeparatorHidden
        nameLabel.textAlignment = .left
        nameLabel.font = viewModel.serverFont
        nameLabel.textColor = viewModel.serverColor
        nameLabel.text = viewModel.serverName
        let url = returnServerImageUrl(symbol: viewModel.serverSymbol)
        if let imageUrl = URL(string: url) {
            if let image = SVGKImage(contentsOf: imageUrl) {
                 if let uiImageInstance = image.uiImage {
                     self.serverImageView.image = uiImageInstance
                 }
              }
        }
    }
    
    func returnServerImageUrl(symbol: String)  -> String{
        return "https://assets.lif3.com/wallet/chains/\(symbol)-Isolated.svg"
    }
}
