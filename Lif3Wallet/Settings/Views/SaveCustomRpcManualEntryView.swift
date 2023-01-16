//
//  EditCustomRPCView.swift
//  AlphaWallet
//
//  Created by Jerome Chan on 7/11/21.
//

import UIKit

@objc protocol KeyboardNavigationDelegate {
    func gotoNextResponder()
    func gotoPrevResponder()
    func addHttpsText()
}

class SaveCustomRpcManualEntryView: UIView {

    private let buttonsBar = HorizontalButtonsBar(configuration: .primary(buttons: 1))
    private var scrollViewBottomConstraint: NSLayoutConstraint!
    private let roundedBackground = RoundedBackground()
    private let scrollView = UIScrollView()

    var chainNameTextField: TextField = {
        let textField = TextField.textField(
            keyboardType: .default,
            placeHolder: R.string.localizable.addrpcServerNetworkNameTitle(),
//            label: R.string.localizable.addrpcServerNetworkNameTitle())
            label: "")
        return textField
    }()

    var rpcEndPointTextField: TextField = {
        let textField = TextField.textField(
            keyboardType: .URL,
            placeHolder: R.string.localizable.addrpcServerRpcUrlPlaceholder(),
//            label: R.string.localizable.addrpcServerRpcUrlTitle())
            label: "")
        return textField
    }()

    var chainIDTextField: TextField = {
        let textField = TextField.textField(
            keyboardType: .numberPad,
            placeHolder: R.string.localizable.chainID(),
//            label: R.string.localizable.chainID())
            label: "")
        return textField
    }()

    var symbolTextField: TextField = {
        let textField = TextField.textField(
            keyboardType: .default,
            placeHolder: R.string.localizable.symbol(),
//            label: R.string.localizable.symbol())
            label: "")
        return textField
    }()

    var explorerEndpointTextField: TextField = {
        let textField = TextField.textField(
            keyboardType: .URL,
            placeHolder: R.string.localizable.addrpcServerBlockExplorerUrlPlaceholder(),
//            label: R.string.localizable.addrpcServerBlockExplorerUrlTitle())
            label: "")
        textField.returnKeyType = .done
        return textField
    }()

    var allTextFields: [TextField] {
        return [chainNameTextField, rpcEndPointTextField, chainIDTextField, symbolTextField, explorerEndpointTextField]
    }

    var isTestNetworkView: SwitchView = {
        let view = SwitchView()

        return view
    }()

    init(frame: CGRect, isEmbedded: Bool) {
        super.init(frame: frame)
        configure(isEmbedded: isEmbedded)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addBackgroundGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        roundedBackground.addGestureRecognizer(gestureRecognizer)
    }

    func configureKeyboard(keyboardChecker: KeyboardChecker) {
        keyboardChecker.constraints = [scrollViewBottomConstraint]
    }

    func addSaveButtonTarget(_ target: Any?, action: Selector) {
        let button = buttonsBar.buttons[0]
        button.removeTarget(target, action: action, for: .touchUpInside)
        button.addTarget(target, action: action, for: .touchUpInside)
    }

    private func configure(isEmbedded: Bool) {
        allTextFields.forEach({
            $0.textField.borderStyle = .none
            $0.cornerRadius = 0
            $0.borderWidth = 0
        })
        
        translatesAutoresizingMaskIntoConstraints = !isEmbedded
        scrollViewBottomConstraint = scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        if !isEmbedded {
            scrollViewBottomConstraint.constant = -UIApplication.shared.bottomSafeAreaHeight
        }
        
        let textFieldStackView = [
            chainNameTextField.defaultLayout(isForNetwork: true),
            rpcEndPointTextField.defaultLayout(isForNetwork: true),
            chainIDTextField.defaultLayout(isForNetwork: true),
            symbolTextField.defaultLayout(isForNetwork: true),
            explorerEndpointTextField.defaultLayout(isForNetwork: true),
        ].asStackView(axis: .vertical)
        textFieldStackView.cornerRadius = 10
        
        let bottomView: UIView = {
            let view = UIView()
            view.backgroundColor = Configuration.Color.Semantic.textFieldBackground
            view.cornerRadius = 10
            view.addSubview(isTestNetworkView)
            isTestNetworkView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                isTestNetworkView.topAnchor.constraint(equalTo: view.topAnchor, constant: 6),
                isTestNetworkView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                isTestNetworkView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                isTestNetworkView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6)
            ])
            return view
        }()

//        let stackView = [
//            chainNameTextField.defaultLayout(),
//            rpcEndPointTextField.defaultLayout(),
//            chainIDTextField.defaultLayout(),
//            symbolTextField.defaultLayout(),
//            explorerEndpointTextField.defaultLayout(),
//            isTestNetworkView,
//            .spacer(height: 40)
//        ].asStackView(axis: .vertical)
        
        let stackView = [
            textFieldStackView,
            bottomView,
            .spacer(height: 40)
        ].asStackView(axis: .vertical)
        stackView.setCustomSpacing(15, after: textFieldStackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        roundedBackground.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(roundedBackground)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        roundedBackground.addSubview(scrollView)

        let footerBar = ButtonsBarBackgroundView(buttonsBar: buttonsBar, edgeInsets: .zero, separatorHeight: 0.0)
        scrollView.addSubview(footerBar)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: footerBar.topAnchor),

            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollViewBottomConstraint,

            footerBar.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            footerBar.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            footerBar.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            footerBar.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            footerBar.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ] + roundedBackground.createConstraintsWithContainer(view: self))
    }

    func configureView() {
        buttonsBar.configure()
        buttonsBar.buttons[0].setTitle(R.string.localizable.editCustomRPCSaveButtonTitle(), for: .normal)
        configureInputAccessoryView()
    }

    func resetAllTextFieldStatus() {
        for field in allTextFields {
            field.status = .none
        }
    }

    private func configureInputAccessoryView() {
        let navToolbar = navToolbar(for: self)
        let urlToolbar = urlToolbar(for: self)
        chainNameTextField.textField.inputAccessoryView = navToolbar
        rpcEndPointTextField.textField.inputAccessoryView = urlToolbar
        chainIDTextField.textField.inputAccessoryView = navToolbar
        symbolTextField.textField.inputAccessoryView = navToolbar
        explorerEndpointTextField.textField.inputAccessoryView = urlToolbar
    }

    private func prevTextField() -> TextField? {
        guard let index = allTextFields.firstIndex(where: { $0.textField.isFirstResponder
        }) else { return nil }
        let prevIndex = (index - 1) < 0 ? allTextFields.count - 1 : index - 1
        return allTextFields[prevIndex]
    }

    private func nextTextField() -> TextField? {
        guard let index = allTextFields.firstIndex(where: { $0.textField.isFirstResponder
        }) else { return nil }
        let nextIndex = (index + 1) % allTextFields.count
        return allTextFields[nextIndex]
    }

    private func currentTextField() -> TextField? {
        return allTextFields.first { $0.textField.isFirstResponder }
    }

}

extension SaveCustomRpcManualEntryView: KeyboardNavigationDelegate {

    func gotoNextResponder() {
        nextTextField()?.becomeFirstResponder()
    }

    func gotoPrevResponder() {
        prevTextField()?.becomeFirstResponder()
    }

    func addHttpsText() {
        // swiftlint:disable empty_enum_arguments
        guard let currentTextField = currentTextField(), let inputString = currentTextField.textField.text, !inputString.lowercased().starts(with: "https://") else { return }
        // swiftlint:enable empty_enum_arguments
        currentTextField.textField.text = "https://" + inputString
    }

}

fileprivate func navToolbar(for delegate: KeyboardNavigationDelegate) -> UIToolbar {
    let toolbar = UIToolbar(frame: .zero)
    let prev = UIBarButtonItem(title: "<", style: .plain, target: delegate, action: #selector(delegate.gotoPrevResponder))
    let next = UIBarButtonItem(title: ">", style: .plain, target: delegate, action: #selector(delegate.gotoNextResponder))
    let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    toolbar.items = [prev, next, flexSpace]
    toolbar.sizeToFit()
    return toolbar
}

fileprivate func urlToolbar(for delegate: KeyboardNavigationDelegate) -> UIToolbar {
    let toolbar = UIToolbar(frame: .zero)
    let prev = UIBarButtonItem(title: "<", style: .plain, target: delegate, action: #selector(delegate.gotoPrevResponder))
    let next = UIBarButtonItem(title: ">", style: .plain, target: delegate, action: #selector(delegate.gotoNextResponder))
    let https = UIBarButtonItem(title: "https://", style: .plain, target: delegate, action: #selector(delegate.addHttpsText))
    let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    toolbar.items = [prev, next, https, flexSpace]
    toolbar.sizeToFit()
    return toolbar
}
