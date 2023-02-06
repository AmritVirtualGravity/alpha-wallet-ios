// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import AlphaWalletFoundation
import RealmSwift

protocol AddContactViewControllerDelegate: AnyObject {
    func openQRCode(in controller: AddContactViewController)
    func didClose(viewController: AddContactViewController)
}




class AddContactViewController: UIViewController {
    
    private var viewModel = AddContactViewModel()
    private lazy var addressTextField: AddressTextField = {
        let textField = AddressTextField(domainResolutionService: domainResolutionService)  
        textField.returnKeyType = .done
        textField.inputAccessoryButtonType = .done
        textField.delegate = self

        return textField
    }()

    private lazy var nameTextField: TextField = {
        let textField = TextField.textField
        textField.inputAccessoryButtonType = .done
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }()
    private let domainResolutionService: DomainResolutionServiceType

    private let buttonsBar = HorizontalButtonsBar(configuration: .primary(buttons: 1))
    private let changeServerButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(Configuration.Color.Semantic.navigationbarButtonItemTint, for: .normal)

        return button
    }()


    weak var delegate: AddContactViewControllerDelegate?

    private lazy var containerView: ScrollableStackView = {
        let containerView = ScrollableStackView()
        containerView.stackView.spacing = ScreenChecker.size(big: 24, medium: 24, small: 20)
        containerView.stackView.axis = .vertical
        containerView.scrollView.showsVerticalScrollIndicator = false

        return containerView
    }()

    init(domainResolutionService: DomainResolutionServiceType) {
        self.domainResolutionService = domainResolutionService
        super.init(nibName: nil, bundle: nil)

        self.hidesBottomBarWhenPushed = true
        self.navigationItem.rightBarButtonItem = .init(customView: changeServerButton)

        self.containerView.stackView.addArrangedSubviews([
            .spacer(height: 0),
            self.nameTextField.defaultLayout(),
            //NOTE: 0 for applying insets of stack view
            self.addressTextField.defaultLayout(edgeInsets: .zero),
        ])

        buttonsBar.buttons[0].isEnabled = true

        let footerBar = ButtonsBarBackgroundView(buttonsBar: buttonsBar)

        view.addSubview(footerBar)
        view.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DataEntry.Metric.Container.xMargin),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DataEntry.Metric.Container.xMargin),
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: footerBar.topAnchor),

            footerBar.anchorsConstraint(to: view)
        ])

    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Configuration.Color.Semantic.defaultViewBackground
        configure()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
    }

    public func configure() {
        addressTextField.label.text = viewModel.addressLabel
        nameTextField.label.text = viewModel.nameLabel
        buttonsBar.configure()
        let saveButton = buttonsBar.buttons[0]
        saveButton.addTarget(self, action: #selector(addContactButtonSelected), for: .touchUpInside)
        saveButton.setTitle(R.string.localizable.settingsContactTitle(), for: .normal)
    }

    @objc private func addContactButtonSelected(_ sender: UIButton) {
        
        if (!validate()) {
            return
        }
        let realm = try! Realm()
        try! realm.write {
            realm.add(ContactRmModel(name: nameTextField.value.trimmed, walletAddress: addressTextField.value.trimmed))
        }
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func validate() -> Bool {
        var validate = false
        
        if !CryptoAddressValidator.isValidAddress(addressTextField.value) {
            addressTextField.errorState = .error("Please enter valid address")
            validate = false
        } else if addressTextField.value.trimmed.isEmpty {
            addressTextField.errorState = .error(R.string.localizable.warningFieldRequired())
            validate = false
        } else if nameTextField.value.trimmed.isEmpty {
            nameTextField.status = .error(R.string.localizable.warningFieldRequired())
            validate = false
        } else if checkIfAddressAlreadyExist(walletAddress: addressTextField.value) {
            addressTextField.errorState = .error("Please enter different address. This address is already used.")
            validate = false
        } else {
            validate = true
        }
        return validate
    }
    
    
    func checkIfAddressAlreadyExist(walletAddress: String) -> Bool{
        let realm = try! Realm()
        let items = realm.objects(ContactRmModel.self)
        return items.contains { contact in
            contact.walletAddress == walletAddress
        }
        
    }
   

    
}



extension AddContactViewController: AddressTextFieldDelegate {
    func doneButtonTapped(for textField: AddressTextField) {
//        symbolTextField.becomeFirstResponder()
        view.endEditing(true)
    }

    func didScanQRCode(_ result: String) {
        switch AddressOrEip681Parser.from(string: result) {
        case .address(let address):
            addressTextField.value = address.eip55String
        case .eip681, .none:
            break
        }
    }

    func displayError(error: Error, for textField: AddressTextField) {
        textField.errorState = .error(error.prettyError)
    }

    func openQRCodeReader(for textField: AddressTextField) {
        delegate?.openQRCode(in: self)
    }

    func didPaste(in textField: AddressTextField) {
        textField.errorState = .none
//        updateContractValue(value: textField.value.trimmed)
        view.endEditing(true)
    }

    func shouldReturn(in textField: AddressTextField) -> Bool {
//        symbolTextField.becomeFirstResponder()
        return true
    }

    func didChange(to string: String, in textField: AddressTextField) {
        if CryptoAddressValidator.isValidAddress(string) {
//            updateContractValue(value: string)
        }
    }
}

extension AddContactViewController: TextFieldDelegate {
    func shouldReturn(in textField: TextField) -> Bool {
        return true
    }
    
    func doneButtonTapped(for textField: TextField) {
        view.endEditing(true)
    }

    func nextButtonTapped(for textField: TextField) {
        view.endEditing(true)
    }
}

