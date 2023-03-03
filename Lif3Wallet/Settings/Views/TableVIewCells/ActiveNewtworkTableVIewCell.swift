//
//  ActiveNewtworkTableVIewCell.swift
//  Lif3Wallet
//
//  Created by Nirajan Shrestha on 14/12/2022.
//

import UIKit
import AlphaWalletFoundation

class ActiveNewtworkTableVIewCell: UITableViewCell {

    // MARK: - Properties

    // MARK: Private
    private let chainIconView: ImageView = {
        let imageView = ImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 30),
            imageView.heightAnchor.constraint(equalToConstant: 30),
        ])
        imageView.cornerRadius = 0
        return imageView
    }()
    
    private let onOffSwitch: UISwitch = {
        let onOffSwitch = UISwitch()
        onOffSwitch.translatesAutoresizingMaskIntoConstraints = false
        onOffSwitch.onTintColor = .green
        onOffSwitch.widthAnchor.constraint(equalToConstant: 50).isActive = true
        return onOffSwitch
    }()
    
    private let warningImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 25.0),
            imageView.heightAnchor.constraint(equalToConstant: 25.0),
        ])
        return imageView
    }()
    
    private let infoView: ServerInformationView = ServerInformationView()
    
    private let topSeparator: UIView = UIView.spacer(backgroundColor: Configuration.Color.Semantic.tableViewSeparator)
    
    private lazy var unavailableToSelectView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = (Configuration.Color.Semantic.defaultViewBackground).withAlphaComponent(0.4)
        view.isHidden = false
        return view
    }()
    
    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        constructView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Configuration and Construction

    // MARK: Public

    func configure(viewModel: ServerImageTableViewCellViewModelType) {
        configureView(viewModel: viewModel)
        configureChainIconView(viewModel: viewModel)
        configureInfoView(viewModel: viewModel)
        onOffSwitch.isOn = (viewModel as! ServerImageViewModel).isSelected
        unavailableToSelectView.isHidden = viewModel.isAvailableToSelect
        warningImageView.image = viewModel.warningImage
        warningImageView.isHidden = viewModel.warningImage == nil
    }

    // MARK: Private

    private func constructView() {
        addSubview(topSeparator)
        addSubview(chainIconView)
        addSubview(infoView)
        addSubview(unavailableToSelectView)

        let accessoryStackView = [warningImageView, onOffSwitch].asStackView(axis: .horizontal, spacing: 10, alignment: .center)
        accessoryStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(accessoryStackView)

        NSLayoutConstraint.activate([
            topSeparator.topAnchor.constraint(equalTo: contentView.topAnchor),
            topSeparator.leadingAnchor.constraint(equalTo: chainIconView.trailingAnchor, constant: 16.0),
            topSeparator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            chainIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            chainIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chainIconView.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: topAnchor, multiplier: 1.0),
            chainIconView.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: bottomAnchor, multiplier: 1.0),

            infoView.leadingAnchor.constraint(equalTo: chainIconView.trailingAnchor, constant: 16.0),
            infoView.trailingAnchor.constraint(equalTo: accessoryStackView.leadingAnchor),
            infoView.centerYAnchor.constraint(equalTo: centerYAnchor),
            infoView.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: topAnchor, multiplier: 1.0),
            infoView.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: bottomAnchor, multiplier: 1.0),

            accessoryStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            accessoryStackView.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: topAnchor, multiplier: 1.0),
            accessoryStackView.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: bottomAnchor, multiplier: 1.0),
            accessoryStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.0),

            unavailableToSelectView.anchorsConstraint(to: self)
        ])
    }

    private func configureView(viewModel: ServerImageTableViewCellViewModelType) {
        selectionStyle = viewModel.selectionStyle
//        topSeparator.isHidden = viewModel.isTopSeparatorHidden
    }

    private func configureChainIconView(viewModel: ServerImageTableViewCellViewModelType) {
        switch viewModel.server {
        case .auto:
            chainIconView.image = R.image.launch_icon()!
        case .server(let server):
            chainIconView.subscribable = server.walletConnectIconImage
        }
    }

    private func configureInfoView(viewModel: ServerImageTableViewCellViewModelType) {
        infoView.configure(viewModel: viewModel)
    }
}

// MARK: - private class

private class ServerInformationView: UIView {

    // MARK: - Properties

    // MARK: Private
    private let primaryTextLabel: UILabel = UILabel()

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        constructView()
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    // MARK: - Configuration and Construction

    // MARK: Public

    func configure(viewModel: ServerImageTableViewCellViewModelType) {
        primaryTextLabel.font = Fonts.regular(size: 18)
        primaryTextLabel.text = viewModel.primaryText
        primaryTextLabel.textColor = viewModel.primaryFontColor
    }

    // MARK: Private
    
    private func constructView() {
        primaryTextLabel.translatesAutoresizingMaskIntoConstraints = false
        primaryTextLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        addSubview(primaryTextLabel)
        NSLayoutConstraint.activate([
            primaryTextLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            primaryTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            primaryTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
