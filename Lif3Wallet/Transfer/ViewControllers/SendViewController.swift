// Copyright © 2018 Stormbird PTE. LTD.
import UIKit
import Combine
import AlphaWalletFoundation

protocol SendViewControllerDelegate: AnyObject, CanOpenURL {
    func didPressConfirm(transaction: UnconfirmedTransaction, in viewController: SendViewController)
    func openQRCode(in viewController: SendViewController)
    func didClose(in viewController: SendViewController)
    func didTapAddAddressToContact(in viewController: SendViewController)
}

class SendViewController: UIViewController {
    private let recipientHeader = SendViewSectionHeader()
    private let amountHeader = SendViewSectionHeader()
    private let contactHeader = SendViewSectionHeader()
    private let buttonsBar: HorizontalButtonsBar = {
        let buttonsBar = HorizontalButtonsBar(configuration: .primary(buttons: 1))
        buttonsBar.configure()
        buttonsBar.buttons[0].setTitle(R.string.localizable.send(), for: .normal)

        return buttonsBar
    }()
    
    private let addToContactButton:UIButton = {
        let button = UIButton()
        button.setTitle("Add to Contact", for: .normal)
        button.titleLabel?.font = Fonts.regular(size: 16)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.isHidden = true
        return button
    }()
    
    private let contactNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.bold(size: 15)
        label.isHidden = true
        return label
    }()
    
    private lazy var contactTableView: UITableView = {
        let tableView = UITableView.insetGroped
        tableView.register(ContactTableViewCell.self)
//        tableView.separatorStyle = .singleLine
        tableView.separatorColor =  .white.withAlphaComponent(0.1)
        tableView.backgroundColor = Configuration.Color.Semantic.defaultViewBackground
        tableView.delegate = self
        tableView.dataSource = self

        return tableView
    }()
    
    public var contactListArr = [ContactRmModel]()
    
    //NOTE: Internal, for tests
    let viewModel: SendViewModel
    //We use weak link to make sure that token alert will be deallocated by close button tapping.
    //We storing link to make sure that only one alert is displaying on the screen.
    private weak var invalidTokenAlert: UIViewController?
    private let domainResolutionService: DomainResolutionServiceType
    private var cancelable = Set<AnyCancellable>()
    private let qrCode = PassthroughSubject<String, Never>()
    private let didAppear = PassthroughSubject<Void, Never>()
    private var sendButton: UIButton { buttonsBar.buttons[0] }
    private lazy var containerView: ScrollableStackView = {
        let view = ScrollableStackView()
        return view
    }()
    lazy var targetAddressTextField: AddressTextField = {
        let targetAddressTextField = AddressTextField(domainResolutionService: domainResolutionService)
        targetAddressTextField.delegate = self
        targetAddressTextField.returnKeyType = .done
        targetAddressTextField.pasteButton.contentHorizontalAlignment = .right
        targetAddressTextField.inputAccessoryButtonType = .done

        return targetAddressTextField
    }()

    lazy var amountTextField: AmountTextField = {
        let amountTextField = AmountTextField(viewModel: viewModel.amountTextFieldViewModel)
        amountTextField.delegate = self
        amountTextField.inputAccessoryButtonType = .next
        amountTextField.viewModel.errorState = .none
        amountTextField.isAlternativeAmountEnabled = true
        amountTextField.isAllFundsEnabled = true
        amountTextField.selectCurrencyButton.hasToken = true

        return amountTextField
    }()
    weak var delegate: SendViewControllerDelegate?

    init(viewModel: SendViewModel, domainResolutionService: DomainResolutionServiceType) {
        self.domainResolutionService = domainResolutionService
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)

        containerView.stackView.addArrangedSubviews([
            amountHeader,
            .spacer(height: ScreenChecker().isNarrowScreen ? 7: 16),
            amountTextField.defaultLayout(edgeInsets: .init(top: 0, left: 16, bottom: 0, right: 16)),
            .spacer(height: ScreenChecker().isNarrowScreen ? 7: 14),
            recipientHeader,
            .spacer(height: ScreenChecker().isNarrowScreen ? 7: 16),
//            contactNameLabel,
//            .spacer(height: ScreenChecker().isNarrowScreen ? 7: 14),
            targetAddressTextField.defaultLayout(edgeInsets: .init(top: 0, left: 16, bottom: 0, right: 16)),
            addToContactButton,
            contactHeader,
            contactTableView
        ])

        let footerBar = ButtonsBarBackgroundView(buttonsBar: buttonsBar, separatorHeight: 0)

        view.addSubview(footerBar)
        view.addSubview(containerView)
        view.addSubview(contactNameLabel)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: footerBar.topAnchor),
            contactTableView.topAnchor.constraint(equalTo: contactHeader.bottomAnchor),
            contactTableView.bottomAnchor.constraint(equalTo: footerBar.topAnchor),
            contactNameLabel.topAnchor.constraint(equalTo: recipientHeader.bottomAnchor, constant: 10),
            contactNameLabel.bottomAnchor.constraint(equalTo: targetAddressTextField.topAnchor, constant: -10),
            contactNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18),
            footerBar.anchorsConstraint(to: view),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addToContactButton.addTarget(self, action: #selector(addContactButtonSelected), for: .touchUpInside)
        view.backgroundColor = Configuration.Color.Semantic.defaultViewBackground
        amountHeader.configure(viewModel: viewModel.amountViewModel)
        recipientHeader.configure(viewModel: viewModel.recipientViewModel)
        contactHeader.configure(viewModel: viewModel.contactViewModel)
        bind(viewModel: viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getContactList()
        showHideAddToContactButton(address: targetAddressTextField.value.trimmed)
    }

    
  
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear.send(())
    }
    
    func getContactList() {
        viewModel.getContacts { contactList in
            self.contactListArr = contactList
            self.contactTableView.reloadData()
        }
    }
    
    func checkIfTheContactAlreadyExists(address: String) -> Bool {
        return self.contactListArr.contains { contact in
            contact.walletAddress == address
        }
    }
    
    
    func showHideAddToContactButton(address: String) {
        if address.isEmpty  || !CryptoAddressValidator.isValidAddress(address) {
            contactNameLabel.isHidden = true
            addToContactButton.isHidden = true
        } else {
            addToContactButton.isHidden = checkIfTheContactAlreadyExists(address: address)
            contactNameLabel.isHidden = !checkIfTheContactAlreadyExists(address: address)
            if  let contact = viewModel.getContact(contactList: contactListArr, address: address) {
                contactNameLabel.text = contact.name
            }
        }
    }
    
    @objc private func addContactButtonSelected(_ sender: UIButton) {
        self.delegate?.didTapAddAddressToContact(in: self)
    }

    func allFundsSelected() {
        amountTextField.allFundsButton.sendActions(for: .touchUpInside)
    }

    private func bind(viewModel: SendViewModel) {
        let send = sendButton.publisher(forEvent: .touchUpInside).eraseToAnyPublisher()
        let recipient = send.map { [targetAddressTextField] _ in return targetAddressTextField.value.trimmed }
            .eraseToAnyPublisher()
        
        let input = SendViewModelInput(
            amountToSend: amountTextField.cryptoValuePublisher,
            qrCode: qrCode.eraseToAnyPublisher(),
            allFunds: amountTextField.allFundsButton.publisher(forEvent: .touchUpInside).eraseToAnyPublisher(),
            send: send,
            recipient: recipient,
            didAppear: didAppear.eraseToAnyPublisher())

        let output = viewModel.transform(input: input)

        output.scanQrCodeError
            .sink { [weak self] in self?.showError(message: $0) }
            .store(in: &cancelable)

        output.activateAmountInput
            .sink { [weak self] _ in self?.activateAmountView() }
            .store(in: &cancelable)

        output.token
            .sink { [weak amountTextField] in amountTextField?.viewModel.set(token: $0) }
            .store(in: &cancelable)

        output.confirmTransaction
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.didPressConfirm(transaction: $0, in: strongSelf)
            }.store(in: &cancelable)

        output.amountTextFieldState
            .sink { [weak amountTextField] in amountTextField?.set(amount: $0.amount) }
            .store(in: &cancelable)

        output.cryptoErrorState
            .sink { [weak amountTextField] in amountTextField?.viewModel.errorState = $0 }
            .store(in: &cancelable)

        output.recipientErrorState
            .sink { [weak targetAddressTextField] in targetAddressTextField?.errorState = $0 }
            .store(in: &cancelable)

        output.viewState
            .sink { [navigationItem, amountTextField, targetAddressTextField] viewState in
                navigationItem.title = viewState.title

                amountTextField.selectCurrencyButton.expandIconHidden = viewState.selectCurrencyButtonState.expandIconHidden

                amountTextField.statusLabel.text = viewState.amountStatusLabelState.text
                amountTextField.availableTextHidden = viewState.amountStatusLabelState.isHidden

                if let recipient = viewState.recipientTextFieldState.recipient {
                    targetAddressTextField.value = recipient
                }
                amountTextField.viewModel.cryptoToFiatRate.value = viewState.rate
            }.store(in: &cancelable)
    }

    private func activateAmountView() {
//        amountTextField.becomeFirstResponder()
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    func didScanQRCode(_ value: String) {
        qrCode.send(value)
    }

    private func showError(message: String) {
        guard invalidTokenAlert == nil else { return }

        invalidTokenAlert = UIAlertController.alert(message: message, alertButtonTitles: [R.string.localizable.oK()], alertButtonStyles: [.cancel], viewController: self)
    }
}

extension SendViewController: PopNotifiable {
    func didPopViewController(animated: Bool) {
        delegate?.didClose(in: self)
    }
}

extension SendViewController: AmountTextFieldDelegate {

    func doneButtonTapped(for textField: AmountTextField) {
        view.endEditing(true)
    }

    func nextButtonTapped(for textField: AmountTextField) {
        targetAddressTextField.becomeFirstResponder()
    }

    func shouldReturn(in textField: AmountTextField) -> Bool {
        targetAddressTextField.becomeFirstResponder()
        return false
    }
}

extension SendViewController: AddressTextFieldDelegate {
    func doneButtonTapped(for textField: AddressTextField) {
        view.endEditing(true)
    }

    func displayError(error: Error, for textField: AddressTextField) {
        textField.errorState = .error(error.prettyError)
    }

    func openQRCodeReader(for textField: AddressTextField) {
        showHideAddToContactButton(address: textField.value)
        delegate?.openQRCode(in: self)
    }

    func didPaste(in textField: AddressTextField) {
        textField.errorState = .none
        showHideAddToContactButton(address: textField.value)
        //NOTE: Comment it as activating amount view doesn't work properly here
        //activateAmountView()
    }

    func shouldReturn(in textField: AddressTextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func didClear(in textField: AddressTextField) {
        showHideAddToContactButton(address: textField.value)
    }
    

    func didChange(to string: String, in textField: AddressTextField) {
        //no-op
        showHideAddToContactButton(address: string)
    }
}

extension SendViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contact = contactListArr[indexPath.row]
            let cell: ContactTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(viewModel: ContactTableViewCellViewModel(name: contact.name, address: contact.walletAddress))
            return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactListArr.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contactListArr[indexPath.row]
        targetAddressTextField.value = contact.walletAddress
        showHideAddToContactButton(address: contact.walletAddress)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
}
   
