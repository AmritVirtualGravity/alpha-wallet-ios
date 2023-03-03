// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import UIKit

protocol DappsHomeViewControllerHeaderViewDelegate: AnyObject {
    func didExitEditMode(inHeaderView: DappsHomeViewControllerHeaderView)
}

class DappsHomeViewControllerHeaderView: UICollectionReusableView {
    private let stackView = [].asStackView(axis: .vertical, distribution: .equalSpacing)
    private let headerView = BrowserHomeHeaderView()
    private let exitEditingModeButton = UIButton(type: .system)

    weak var delegate: DappsHomeViewControllerHeaderViewDelegate?
    let myDappsButton = DappButton()
    let historyButton = DappButton()
    let bookMarksLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let buttonsStackView = [
            myDappsButton,
            .spacerWidth(10),
            historyButton
        ].asStackView(distribution: .equalSpacing, contentHuggingPriority: .required)

        exitEditingModeButton.addTarget(self, action: #selector(exitEditMode), for: .touchUpInside)
        exitEditingModeButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(exitEditingModeButton)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        
      
        stackView.addArrangedSubviews([
//            headerView,
            buttonsStackView,
            .spacer(height: 60),
            bookMarksLabel
        ])
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 50),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -22),
            stackView.bottomAnchor.constraint(equalTo: exitEditingModeButton.topAnchor, constant: 0),
            myDappsButton.widthAnchor.constraint(equalTo: historyButton.widthAnchor),
            bookMarksLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            exitEditingModeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22),
            exitEditingModeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: DappsHomeViewControllerHeaderViewViewModel = .init(isEditing: false)) {
        backgroundColor = viewModel.backgroundColor

        headerView.configure(viewModel: .init(title: viewModel.title))

        myDappsButton.configure(viewModel: .init(image: viewModel.myDappsButtonImage, title: viewModel.myDappsButtonTitle))

        historyButton.configure(viewModel: .init(image: viewModel.historyButtonImage, title: viewModel.historyButtonTitle))
        bookMarksLabel.text = viewModel.bookmarksTitle
        bookMarksLabel.textAlignment = .left
        bookMarksLabel.textColor = Configuration.Color.Semantic.defaultTitleText
        bookMarksLabel.font = viewModel.font
        if viewModel.isEditing {
            exitEditingModeButton.isHidden = false
            exitEditingModeButton.setTitle(R.string.localizable.done().localizedUppercase, for: .normal)
            exitEditingModeButton.titleLabel?.font = Fonts.bold(size: 12)

            myDappsButton.isEnabled = false
            historyButton.isEnabled = false
        } else {
            exitEditingModeButton.isHidden = true

            myDappsButton.isEnabled = true
            historyButton.isEnabled = true
        }
    }

    @objc private func exitEditMode() {
        configure(viewModel: .init(isEditing: false))
        delegate?.didExitEditMode(inHeaderView: self)
    }
}
