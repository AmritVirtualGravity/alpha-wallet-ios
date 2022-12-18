


import UIKit
import AlphaWalletFoundation
import Combine

protocol SecurityViewControllerDelegate: AnyObject {
    func createPasswordSelected(in controller: SecurityViewController)
}

class SecurityViewController: UIViewController {
    private let viewModel: SecurityViewModel
    private lazy var tableView: UITableView = {
        let tableView = UITableView.insetGroped
        tableView.register(SwitchTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self

        return tableView
    }()
    
    weak var delegate: SecurityViewControllerDelegate?
    
    private let appProtectionSelection = PassthroughSubject<(indexPath: IndexPath, isOn: Bool), Never>()
    private let willAppear = PassthroughSubject<Void, Never>()
    private var cancellable = Set<AnyCancellable>()
    init(viewModel: SecurityViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.anchorsIgnoringBottomSafeArea(to: view)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure(viewModel: viewModel)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        willAppear.send(())
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    private func configure(viewModel: SecurityViewModel) {
        
        title = viewModel.title
        let input = SecurityViewModelInput(
            willAppear: willAppear.eraseToAnyPublisher(),
            appProtectionSelection: appProtectionSelection.eraseToAnyPublisher())
        let output = viewModel.transform(input: input)
        output.askToSetPasscode
            .sink { _ in self.delegate?.createPasswordSelected(in: self) }
            .store(in: &cancellable)
    }
}

extension SecurityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SwitchTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel: viewModel.viewModel(for: indexPath))
        cell.delegate = self
        return cell
    }
}

extension SecurityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

 
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        nil
    }

    //Hide the footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
}

extension SecurityViewController: SwitchTableViewCellDelegate {
    func cell(_ cell: SwitchTableViewCell, switchStateChanged isOn: Bool) {
        guard let indexPath = cell.indexPath else { return }
        appProtectionSelection.send((indexPath, isOn))
      
    }
}
