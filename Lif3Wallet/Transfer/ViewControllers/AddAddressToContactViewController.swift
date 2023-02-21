//
//  AddAddressToContactViewController.swift
//  Lif3Wallet
//
//  Created by Vanila Tech Bibhut on 2/21/23.
//

import UIKit

protocol AddAddressToContactViewControllerDelegate {
    func didTapOutside(in viewController: AddAddressToContactViewController)
    func didTapCreateContact(in viewController: AddAddressToContactViewController)
}

class AddAddressToContactViewController: UIViewController {
    
    public var delegate: AddAddressToContactViewControllerDelegate?
    private var addAddressToContactPopView: AddAddressToContactPopView = {
        let popView = AddAddressToContactPopView()
        popView.layer.cornerRadius = 12
        return popView
    }()
    
    private let viewModel = AddAddressToContactViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
       
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        addAddressToContactPopView.didTapAddContact = {
            self.didTapAddContact()
        }
        addAddressToContactPopView.configure(viewModel: viewModel.popViewModel)
        // Do any additional setup after loading the view.
    }
    
    func didTapAddContact() {
        self.delegate?.didTapCreateContact(in: self)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        self.delegate?.didTapOutside(in: self)
    }
    
    
    init(){
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .black.withAlphaComponent(0.8)
        view.addSubview(addAddressToContactPopView)
        NSLayoutConstraint.activate([
            addAddressToContactPopView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addAddressToContactPopView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            addAddressToContactPopView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.75),
            addAddressToContactPopView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.30),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


