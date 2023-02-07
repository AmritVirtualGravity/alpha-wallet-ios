//
//  ContactsListViewController.swift
//  Lif3Wallet
//
//  Created by  Bibhut on 2/2/23.
//

import UIKit
import AlphaWalletFoundation
import RealmSwift



protocol ContactsListViewControllerDelegate: AnyObject {
    func didSelectAddContact(in viewController: ContactsListViewController)
    
    func didSelectContactList(in viewController: ContactsListViewController, contact: ContactRmModel?, contactIndex: Int?)
}

class ContactsListViewController: UIViewController {
    
    var delegate: ContactsListViewControllerDelegate?
    var viewModel = ContactListViewModel()
    
    // MARK: - Contants
    static func instantiate() -> ContactsListViewController {
        let controllerStr = String(describing: ContactsListViewController.self)
        return UIStoryboard(name: "Contact", bundle: nil).instantiateViewController(withIdentifier: controllerStr) as! ContactsListViewController
    }
    @IBOutlet weak var noContactsLabel: UILabel!
    
    
    @IBOutlet weak var contactTableView: UITableView! {
        didSet {
            contactTableView.delegate = self
            contactTableView.dataSource = self
        }
    }
    
    @IBOutlet weak var addContactsButton: UIButton! {
        didSet {
            addContactsButton.layer.cornerRadius = 10
            addContactsButton.setTitle("Add Contact", for: .normal)
            addContactsButton.backgroundColor = Configuration.Color.Semantic.primaryButtonBackground
            addContactsButton.setTitleColor(.black, for: .normal)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contacts"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        contactTableView.reloadData()
        noContactsLabel.isHidden = viewModel.getContacts().count <= 0 ? false : true
        contactTableView.isHidden = viewModel.getContacts().count <= 0 ? true : false
    }

    @IBAction func didTapAddContact(_ sender: Any) {
        self.delegate?.didSelectAddContact(in: self)
    }
    
}
