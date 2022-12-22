// Copyright © 2019 Stormbird PTE. LTD.

import UIKit
import AlphaWalletFoundation

protocol SeedPhraseBackupIntroductionViewControllerDelegate: AnyObject {
    func didTapBackupWallet(inViewController viewController: SeedPhraseBackupIntroductionViewController)
    func didClose(for account: AlphaWallet.Address, inViewController viewController: SeedPhraseBackupIntroductionViewController)
}

class SeedPhraseBackupIntroductionViewController: UIViewController {
    private var viewModel = SeedPhraseBackupIntroductionViewModel()
    private let account: AlphaWallet.Address
    private let roundedBackground = RoundedBackground()
    private let subtitleLabel = UILabel()
    private let imageView = UIImageView()
    private let contractView1 = SeedPhraseContractView()
    private let contractView2 = SeedPhraseContractView()
    private let contractView3 = SeedPhraseContractView()

    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = R.image.lifeBackgroundImage()!
        return imageView
    }()
    
    // NOTE: internal level, for test cases
    let descriptionLabel1 = UILabel()
    let buttonsBar = HorizontalButtonsBar(configuration: .primary(buttons: 1))

    private var imageViewDimension: CGFloat {
        return ScreenChecker.size(big: 200, medium: 200, small: 180)
    }

    weak var delegate: SeedPhraseBackupIntroductionViewControllerDelegate?

    init(account: AlphaWallet.Address) {
        self.account = account
        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true
        contractView1.translatesAutoresizingMaskIntoConstraints = false
        contractView2.translatesAutoresizingMaskIntoConstraints = false
        contractView3.translatesAutoresizingMaskIntoConstraints = false
        roundedBackground.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(backgroundImageView)
        view.addSubview(roundedBackground)

        imageView.contentMode = .scaleAspectFit

        let stackView = [
            subtitleLabel,
            UIView.spacer(height: ScreenChecker.size(big: 10, medium: 10, small: 10)),
            descriptionLabel1,
            imageView,
            UIView.spacer(height: ScreenChecker.size(big: 10, medium: 10, small: 10)),
            contractView1,
            UIView.spacer(height: ScreenChecker.size(big: 10, medium: 10, small: 10)),
            contractView2,
            UIView.spacer(height: ScreenChecker.size(big: 10, medium: 10, small: 10)),
            contractView3,
            UIView.spacer(height: ScreenChecker.size(big: 10, medium: 10, small: 10)),
            ].asStackView(axis: .vertical)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        roundedBackground.addSubview(stackView)

        let footerBar = UIView()
        footerBar.translatesAutoresizingMaskIntoConstraints = false
        footerBar.backgroundColor = .clear
        roundedBackground.addSubview(footerBar)
        
        footerBar.addSubview(buttonsBar)

        NSLayoutConstraint.activate([
//            // image view constraits for  full screen size
//            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
//            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
//            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
//            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: -100),
            
            contractView1.heightAnchor.constraint(equalToConstant: 80),
            contractView2.heightAnchor.constraint(equalToConstant: 80),
            contractView3.heightAnchor.constraint(equalToConstant: 80),
            
            imageView.heightAnchor.constraint(equalToConstant: imageViewDimension),
            
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: footerBar.topAnchor),

            buttonsBar.leadingAnchor.constraint(equalTo: footerBar.leadingAnchor),
            buttonsBar.trailingAnchor.constraint(equalTo: footerBar.trailingAnchor),
            buttonsBar.bottomAnchor.constraint(equalTo: footerBar.bottomAnchor),
            buttonsBar.heightAnchor.constraint(equalToConstant: HorizontalButtonsBar.buttonsHeight),

            footerBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).set(priority: .defaultHigh),
            footerBar.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -Style.insets.safeBottom).set(priority: .required),
            footerBar.topAnchor.constraint(equalTo: buttonsBar.topAnchor),

        ] + roundedBackground.anchorsConstraint(to: view))
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBarTopSeparatorLine()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showNavigationBarTopSeparatorLine()
    }

    func configure() {
        backgroundImageView.image = viewModel.backgroundImage
        subtitleLabel.numberOfLines = 0
        subtitleLabel.attributedText = viewModel.attributedSubtitle
        subtitleLabel.textColor = Configuration.Color.Semantic.defaultTitleText
        imageView.image = viewModel.imageViewImage

        descriptionLabel1.numberOfLines = 0
        descriptionLabel1.attributedText = viewModel.attributedDescription
        descriptionLabel1.textColor = Configuration.Color.Semantic.defaultTitleText
        descriptionLabel1.font = UIFont.systemFont(ofSize: 17.0)
        
        // contract view setup
        setupContractView()
        buttonsBar.configure()
        let exportButton = buttonsBar.buttons[0]
        exportButton.setTitle(viewModel.title, for: .normal)
        exportButton.addTarget(self, action: #selector(tappedExportButton), for: .touchUpInside)
    }
    
    private func setupContractView() {
        contractView1.descriptionLabel.text =  "If I lose my secret phrase, my funds will be lost forever"
        contractView2.descriptionLabel.text =  "If I expose or share my secret phrase to anybody my funds can get stolen."
        contractView3.descriptionLabel.text =  "Lif3 Wallet support will NEVER reach out to ask for your Seed Phrase."
    }

    @objc private func tappedExportButton() {
        if (contractView1.getToggleStatus() == true && contractView2.getToggleStatus() == true && contractView3.getToggleStatus() == true) {
            delegate?.didTapBackupWallet(inViewController: self)
        } else {
            if let controller = self.navigationController {
                UIApplication.shared
                    .presentedViewController(or: controller)
                    .displayError(message: "Please select all the checkbox before proceeding")
            }
          
        }
        
       
    }
}

extension SeedPhraseBackupIntroductionViewController: PopNotifiable {
    func didPopViewController(animated: Bool) {
        delegate?.didClose(for: account, inViewController: self)
    }
}