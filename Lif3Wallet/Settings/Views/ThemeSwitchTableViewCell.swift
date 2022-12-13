

import UIKit

protocol ThemeSwitchTableViewCellDelegate: AnyObject {
    func didChangeTheme(_ cell: ThemeSwitchTableViewCell, switchStateChanged isOn: Bool)
}

class ThemeSwitchTableViewCell: UITableViewCell {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let switchView: UISwitch = {
        let switchView = UISwitch()
        switchView.translatesAutoresizingMaskIntoConstraints = false
        return switchView
    }()

    var isOn: Bool {
        get { return switchView.isOn }
        set { switchView.isOn = newValue }
    }

    weak var delegate: ThemeSwitchTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)

        selectionStyle = .none
        accessoryType = .none

        let stackView = [
            iconImageView, titleLabel, .spacerWidth(flexible: true), switchView
        ].asStackView(axis: .horizontal, spacing: 16, alignment: .center)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),

            stackView.anchorsConstraint(to: contentView, edgeInsets: .init(top: 10, left: 16, bottom: 10, right: 20))
        ])
    }

    @objc private func switchChanged(_ sender: UISwitch) {
        delegate?.didChangeTheme(self, switchStateChanged: sender.isOn)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: ThemeSwitchTableViewCellViewModel) {
        titleLabel.text = viewModel.titleText
        titleLabel.font = viewModel.titleFont
        titleLabel.textColor = viewModel.titleTextColor
        iconImageView.image = viewModel.icon
//        switchView.isOn = viewModel.value
        let usrDefault = UserDefaults.standard
        switchView.isOn =   usrDefault.bool(forKey: "DarkModeOn")
    }
}

