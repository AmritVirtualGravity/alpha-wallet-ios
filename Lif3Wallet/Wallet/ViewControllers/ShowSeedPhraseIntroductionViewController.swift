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

    
    private let contractView1 = SeedPhraseContractView()
    private let contractView2 = SeedPhraseContractView()
    private let contractView3 = SeedPhraseContractView()
    
    private var imageViewDimension: CGFloat {
        return ScreenChecker.size(big: 250, medium: 250, small: 250)
    }
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = R.image.lifeBackgroundImage()!
        return imageView
    }()

    weak var delegate: ShowSeedPhraseIntroductionViewControllerDelegate?

    init() {
        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true

        imageView.contentMode = .scaleAspectFit

        let stackView = [
            subtitleLabel,
            UIView.spacer(height: ScreenChecker.size(big: 5, medium: 5, small: 5)),
            descriptionLabel1,
            imageView,
            contractView1,
            UIView.spacer(height: ScreenChecker.size(big: 10, medium: 10, small: 10)),
            contractView2,
            UIView.spacer(height: ScreenChecker.size(big: 10, medium: 10, small: 10)),
            contractView3,
        ].asStackView(axis: .vertical)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contractView1.translatesAutoresizingMaskIntoConstraints = false
        contractView2.translatesAutoresizingMaskIntoConstraints = false
        contractView3.translatesAutoresizingMaskIntoConstraints = false

        let footerBar = ButtonsBarBackgroundView(buttonsBar: buttonsBar, separatorHeight: 0.0)

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
//        container.addSubview(backgroundImageView)
        container.addSubview(stackView)

        view.addSubview(container)
        view.addSubview(footerBar)

        NSLayoutConstraint.activate([
            // image view constraits for  full screen size
//            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
//            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
//            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
//            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: -100),
            
            // Contract View height
            contractView1.heightAnchor.constraint(equalToConstant: 80),
            contractView2.heightAnchor.constraint(equalToConstant: 80),
            contractView3.heightAnchor.constraint(equalToConstant: 80),
            
            imageView.heightAnchor.constraint(equalToConstant: imageViewDimension),

            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor, constant: 16),
            

            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            container.bottomAnchor.constraint(equalTo: footerBar.topAnchor),

            footerBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).set(priority: .defaultHigh),
            footerBar.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -Style.insets.safeBottom).set(priority: .required),
            footerBar.topAnchor.constraint(equalTo: buttonsBar.topAnchor),
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
        view.backgroundColor = Configuration.Color.Semantic.defaultViewBackground

        subtitleLabel.numberOfLines = 0
        subtitleLabel.attributedText = viewModel.attributedSubtitle
        subtitleLabel.textColor = .white
        imageView.image = viewModel.imageViewImage

        descriptionLabel1.numberOfLines = 0
        descriptionLabel1.attributedText = viewModel.attributedDescription
        descriptionLabel1.textColor = .white
        setupContractView()
        buttonsBar.configure()
        let showSeedPhraseButton = buttonsBar.buttons[0]
        showSeedPhraseButton.setTitle(viewModel.title, for: .normal)
        showSeedPhraseButton.addTarget(self, action: #selector(showSeedPhraseSelected), for: .touchUpInside)
    }
    
    private func setupContractView() {
        contractView1.descriptionLabel.text =  "If I lose my secret phrase, my funds will be lost forever"
        contractView2.descriptionLabel.text =  "If I expose or share my secret phrase to anybody my funds can get stolen."
        contractView3.descriptionLabel.text =  "Lif3 Wallet support will NEVER reach out to ask for your Seed Phrase."
    }

    @objc private func showSeedPhraseSelected() {
        if (contractView1.getToggleStatus() == true && contractView2.getToggleStatus() == true && contractView3.getToggleStatus() == true) {
            delegate?.didShowSeedPhrase(in: self)
        } else {
            if let controller = self.navigationController {
                UIApplication.shared
                    .presentedViewController(or: controller)
                    .displayError(message: "Please select all the checkbox before proceeding")
            }
        }
    }
}

extension ShowSeedPhraseIntroductionViewController: PopNotifiable {
    func didPopViewController(animated: Bool) {
        delegate?.didClose(in: self)
    }
}
