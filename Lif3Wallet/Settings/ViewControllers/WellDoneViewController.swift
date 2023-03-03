// Copyright SIX DAY LLC. All rights reserved.
import UIKit

enum WellDoneAction {
    case other
}

protocol WellDoneViewControllerDelegate: AnyObject {
    func didPress(action: WellDoneAction, sender: UIView, in viewController: WellDoneViewController)
}

class WellDoneViewController: UIViewController {
    weak var delegate: WellDoneViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let imageView = UIImageView(image: R.image.mascot_happy())
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = R.string.localizable.welldoneTitleLabelText()
        titleLabel.font = Fonts.regular(size: 30)
        titleLabel.textColor = Configuration.Color.Semantic.defaultForegroundText
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center

        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = R.string.localizable.welldoneDescriptionLabelText()
        descriptionLabel.font = Fonts.regular(size: 18)
        descriptionLabel.textColor = Configuration.Color.Semantic.defaultForegroundText
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center

        let otherButton = Button(size: .normal, style: .solid)
        otherButton.translatesAutoresizingMaskIntoConstraints = false
        otherButton.layer.cornerRadius = 15
        otherButton.setBackgroundColor(.white, forState: .normal)
        otherButton.setTitleColor(.black, for: .normal)
        otherButton.setTitle(R.string.localizable.welldoneShareLabelText(), for: .normal)
        otherButton.addTarget(self, action: #selector(other(_:)), for: .touchUpInside)

        let stackView = [
            imageView,
            titleLabel,
            .spacer(height: 5),
            descriptionLabel,
            .spacer(height: 10),
            .spacer(),
            otherButton,
        ].asStackView(axis: .vertical, spacing: 10, alignment: .center)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = Configuration.Color.Semantic.dialogBackground
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),

            otherButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            otherButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc private func other(_ sender: UIView) {
        delegate?.didPress(action: .other, sender: sender, in: self)
    }
}
