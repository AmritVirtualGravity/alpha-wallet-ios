


import UIKit

extension ContactsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contact = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactListTableViewCell") as! ContactListTableViewCell
        cell.contactNameLabel.text = contact.name
        cell.contactAddressLabel.text = contact.walletAddress
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
}
