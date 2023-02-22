//
//  AddAddressToContactPopView.swift
//  Lif3Wallet
//
//  Created by Vanila Tech Bibhut on 2/21/23.
//



import UIKit



class AddAddressToContactPopView: UIView {

    
    public var didTapAddContact: (() ->())?
    private let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)

        return label
    }()
    
    public lazy var nameTextField: TextField = {
        let textField = TextField.textField
        textField.inputAccessoryButtonType = .done
        textField.returnKeyType = .done
       
        textField.delegate = self
        return textField
    }()
    
    
    private let buttonsBar = HorizontalButtonsBar(configuration: .primary(buttons: 1))
    private let button: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 14.0
        button.backgroundColor = Configuration.Color.Semantic.primaryButtonBackground
        return button
    }()

    init() {
        super.init(frame: .zero)
        buttonsBar.buttons[0].isEnabled = true
        let footerBar = ButtonsBarBackgroundView(buttonsBar: buttonsBar)
        translatesAutoresizingMaskIntoConstraints = false
        let stackView = [
            textLabel,
            nameTextField,
            footerBar
        ].asStackView(axis: .vertical, spacing: 2)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        return nil
    }

    func configure(viewModel: AddAddressToContactPopViewModel) {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
        textLabel.text = viewModel.titleText
        textLabel.textColor = viewModel.textColor
        textLabel.font = viewModel.font
        nameTextField.placeholder = viewModel.placeHolder
        backgroundColor = viewModel.backgroundColor
        nameTextField.textField.textColor = viewModel.textColor
        buttonsBar.configure()
        let saveButton = buttonsBar.buttons[0]
        saveButton.setTitle(viewModel.buttonTitleText, for: .normal)
        saveButton.addTarget(self, action: #selector(addContactButtonSelected), for: .touchUpInside)
    }
    
    
    @objc private func addContactButtonSelected(_ sender: UIButton) {
        if let addContact = didTapAddContact {
            addContact()
        }
    }
}

extension AddAddressToContactPopView: TextFieldDelegate {
    func shouldReturn(in textField: TextField) -> Bool {
       endEditing(true)
        return true
    }
    
    func doneButtonTapped(for textField: TextField) {
       endEditing(true)
    }

    func nextButtonTapped(for textField: TextField) {
       endEditing(true)
    }
}
