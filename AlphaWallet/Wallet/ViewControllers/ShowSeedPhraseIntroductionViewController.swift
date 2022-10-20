//
//  ShowSeedPhraseIntroductionViewController.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 03.03.2021.
//

import UIKit
import AlphaWalletFoundation

protocol ShowSeedPhraseIntroductionViewControllerDelegate: AnyObject {
    func didShowSeedPhrase(in viewController: ShowSeedPhraseIntroductionViewController)
    func didClose(in viewController: ShowSeedPhraseIntroductionViewController)
}

class ShowSeedPhraseIntroductionViewController: UIViewController {

    private var viewModel = ShowSeedPhraseIntroductionViewModel()
    private let subtitleLabel = UILabel()
    private let imageView = UIImageView()
    private let descriptionLabel1 = UILabel()
    private let buttonsBar = HorizontalButtonsBar(configuration: .primary(buttons: 1))

    private var imageViewDimension: CGFloat {
        return ScreenChecker.size(big: 250, medium: 250, small: 250)
    }
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
   

    weak var delegate: ShowSeedPhraseIntroductionViewControllerDelegate?

    init() {
        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true

        imageView.contentMode = .scaleAspectFit

        let stackView = [
            UIView.spacer(height: ScreenChecker.size(big: 32, medium: 22, small: 18)),
            subtitleLabel,
            UIView.spacer(height: ScreenChecker.size(big: 20, medium: 20, small: 18)),
            imageView,
            UIView.spacer(height: ScreenChecker.size(big: 20, medium: 15, small: 10)),
            descriptionLabel1,
        ].asStackView(axis: .vertical)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let footerBar = ButtonsBarBackgroundView(buttonsBar: buttonsBar, separatorHeight: 0.0)

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(backgroundImageView)
        container.addSubview(stackView)
        
        view.addSubview(container)
        view.addSubview(footerBar)

        NSLayoutConstraint.activate([
            
            // image view constraits for  full screen size
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: -100),
       
            
            imageView.heightAnchor.constraint(equalToConstant: imageViewDimension),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor, constant: 16),

            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            container.bottomAnchor.constraint(equalTo: footerBar.topAnchor),

            footerBar.anchorsConstraint(to: view)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    private func configure() {
        backgroundImageView.image = viewModel.backgroundImage
        subtitleLabel.numberOfLines = 0
        subtitleLabel.attributedText = viewModel.attributedSubtitle

        imageView.image = viewModel.imageViewImage

        descriptionLabel1.numberOfLines = 0
        descriptionLabel1.attributedText = viewModel.attributedDescription
        descriptionLabel1.textColor = .white

        buttonsBar.configure()
        let showSeedPhraseButton = buttonsBar.buttons[0]
        showSeedPhraseButton.setTitle(viewModel.title, for: .normal)
        showSeedPhraseButton.addTarget(self, action: #selector(showSeedPhraseSelected), for: .touchUpInside)
    }

    @objc private func showSeedPhraseSelected() {
        delegate?.didShowSeedPhrase(in: self)
    }
}

extension ShowSeedPhraseIntroductionViewController: PopNotifiable {
    func didPopViewController(animated: Bool) {
        delegate?.didClose(in: self)
    }
}
