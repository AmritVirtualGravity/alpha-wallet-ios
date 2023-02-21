//
//  ContactTableViewCell.swift
//  Lif3Wallet
//
//  Created by Bibhut on 2/20/23.


import UIKit
import Combine

class ContactTableViewCell: UITableViewCell {
    

    private let contactLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.clipsToBounds = false

        return label
    }()

    private let addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)

        label.clipsToBounds = false

        return label
    }()
    var walletNameCancelable: AnyCancellable?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = Configuration.Color.Semantic.defaultViewBackground
        let stackView = [
            contactLabel,
            addressLabel
        ].asStackView(axis: .vertical, spacing: 0)
       

        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.anchorsConstraint(to: contentView, edgeInsets: .init(top: 5, left: 16, bottom: 5, right: 10))
        ])
    }

    override func prepareForReuse() {
        accessoryView = nil
        walletNameCancelable?.cancel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: ContactTableViewCellViewModel) {
        contactLabel.text = viewModel.name
        contactLabel.font = viewModel.titleFont
        contactLabel.textColor = viewModel.titleTextColor
        
        addressLabel.text = viewModel.address
        addressLabel.font = viewModel.subTitleFont
        addressLabel.textColor = viewModel.subTitleTextColor
     
    }
}
