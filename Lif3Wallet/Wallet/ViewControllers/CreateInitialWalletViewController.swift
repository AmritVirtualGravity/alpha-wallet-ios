// Copyright © 2019 Stormbird PTE. LTD.

import UIKit
import AlphaWalletFoundation

protocol CreateInitialWalletViewControllerDelegate: AnyObject {
    func didTapCreateWallet(inViewController viewController: CreateInitialWalletViewController)
    func didTapWatchWallet(inViewController viewController: CreateInitialWalletViewController)
    func didTapImportWallet(inViewController viewController: CreateInitialWalletViewController)
}

class CreateInitialWalletViewController: UIViewController {
    private let keystore: Keystore
    private var viewModel = CreateInitialViewModel()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let buttonsBar = VerticalButtonsBar(numberOfButtons: 2)
    weak var delegate: CreateInitialWalletViewControllerDelegate?

    init(keystore: Keystore) {
        self.keystore = keystore
        super.init(nibName: nil, bundle: nil)

        let footerBar = UIView()
        footerBar.translatesAutoresizingMaskIntoConstraints = false
        footerBar.backgroundColor = .clear
        view.addSubview(imageView)
        view.addSubview(footerBar)
        footerBar.addSubview(buttonsBar)
        let footerBottomConstraint = footerBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        footerBottomConstraint.constant = -UIApplication.shared.bottomSafeAreaHeight
        NSLayoutConstraint.activate([
            
            // image view constraits for  full screen size
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),

            buttonsBar.topAnchor.constraint(equalTo: footerBar.topAnchor),
            buttonsBar.bottomAnchor.constraint(equalTo: footerBar.bottomAnchor, constant: -10),
            buttonsBar.leadingAnchor.constraint(equalTo: footerBar.leadingAnchor, constant: 20),
            buttonsBar.trailingAnchor.constraint(equalTo: footerBar.trailingAnchor, constant: -20),

            footerBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerBottomConstraint,
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = UIKitFactory.defaultView(autoResizingMarkIntoConstraints: true)
    }

    func configure() {
        imageView.image = viewModel.imageViewImage
        let createWalletButton = buttonsBar.buttons[0]
        createWalletButton.setTitle(viewModel.createWalletButtonTitle, for: .normal)
        createWalletButton.addTarget(self, action: #selector(createWalletSelected), for: .touchUpInside)
        let alreadyHaveWalletButton = buttonsBar.buttons[1]
        alreadyHaveWalletButton.setTitle(viewModel.alreadyHaveWalletButtonText, for: .normal)
        alreadyHaveWalletButton.addTarget(self, action: #selector(alreadyHaveWalletWallet), for: .touchUpInside)
    }

    @objc private func createWalletSelected(_ sender: UIButton) {
        delegate?.didTapCreateWallet(inViewController: self)
    }

    @objc private func alreadyHaveWalletWallet(_ sender: UIButton) {
        let viewController = makeAlreadyHaveWalletAlertSheet(sender: sender)
        present(viewController, animated: true)
    }

    private func makeAlreadyHaveWalletAlertSheet(sender: UIView) -> UIAlertController {
        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        alertController.popoverPresentationController?.sourceView = sender
        alertController.popoverPresentationController?.sourceRect = sender.centerRect

        let importWalletAction = UIAlertAction(title: viewModel.importButtonTitle, style: .default) { _ in
            self.delegate?.didTapImportWallet(inViewController: self)
        }

        let trackWalletAction = UIAlertAction(title: viewModel.watchButtonTitle, style: .default) { _ in
            self.delegate?.didTapWatchWallet(inViewController: self)
        }

        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel) { _ in }

        alertController.addAction(importWalletAction)
        alertController.addAction(trackWalletAction)
        alertController.addAction(cancelAction)

        return alertController
    }
}
