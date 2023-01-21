// Copyright © 2018 Stormbird PTE. LTD.
import Foundation
import UIKit
import CoreImage
import MBProgressHUD
import Combine
import AlphaWalletFoundation

protocol RequestViewControllerDelegate: AnyObject {
    func didClose(in viewController: RequestViewController)
}

class RequestViewController: UIViewController {
    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.attributedText = viewModel.instructionAttributedString
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        return label
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = R.image.lifeBackgroundImage()!
        return imageView
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let qrCodeDimensions: CGFloat = ScreenChecker.size(big: 260, medium: 260, small: 200)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: qrCodeDimensions),
            imageView.heightAnchor.constraint(equalToConstant: qrCodeDimensions)
        ])

        return imageView
    }()

    private lazy var addressView: RoundedEnsView = {
        return RoundedEnsView(viewModel: .init(text: ""))
    }()

    private lazy var ensNameView: RoundedEnsView = {
        return RoundedEnsView(viewModel: .init(text: ""))
    }()

    private let viewModel: RequestViewModel
    private var cancelable = Set<AnyCancellable>()

    weak var delegate: RequestViewControllerDelegate?

    init(viewModel: RequestViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        let stackView = [
            .spacer(height: ScreenChecker.size(big: 50, medium: 50, small: 20)),
            instructionLabel,
            .spacer(height: ScreenChecker.size(big: 50, medium: 50, small: 15)),
            imageView,
            .spacer(height: ScreenChecker.size(big: 50, medium: 50, small: 15)),
            addressView,
            .spacer(height: ScreenChecker.size(big: 50, medium: 50, small: 15)),
            ensNameView
        ].asStackView(axis: .vertical, alignment: .center)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
//        view.addSubview(backgroundImageView)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            // image view constraits for  full screen size
//            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
//            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
//            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
//            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: -100),
            
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bind(viewModel: viewModel)
    }

    private func bind(viewModel: RequestViewModel) {
        view.backgroundColor = viewModel.backgroundColor

        let input = RequestViewModelInput(copyEns: ensNameView.tapPublisher, copyAddress: addressView.tapPublisher)
        let output = viewModel.transform(input: input)

        output.viewState
            .sink { [imageView, ensNameView, addressView, navigationItem] viewState in
                imageView.image = viewState.qrCode
                imageView.layoutIfNeeded()

                ensNameView.configure(viewModel: .init(text: viewState.ensName))
                addressView.configure(viewModel: .init(text: viewState.address))
                navigationItem.title = viewState.title
            }.store(in: &cancelable)

        output.copiedToClipboard
            .sink { [weak self] in self?.view.showCopiedToClipboard(title: $0) }
            .store(in: &cancelable)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RequestViewController: PopNotifiable {
    func didPopViewController(animated: Bool) {
        delegate?.didClose(in: self)
    }
}