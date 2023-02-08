// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import UIKit

class DappButton: UIControl {
    
   private let imageView: UIImageView = {
        let imageView = UIImageView()
       imageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 30),
        ])
        return imageView
    }()
   
    
    private let label =  UILabel()
    private var viewModel: DappButtonViewModel?
    override var isEnabled: Bool {
        didSet {
            guard let viewModel = viewModel else { return }
            configure(viewModel: viewModel)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let stackView = [imageView, label].asStackView(
                axis: .horizontal,
                spacing: 10, contentHuggingPriority: .required,
                alignment: .center
        )
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
//            stackView.topAnchor.constraint(equalTo: topAnchor),
//            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.anchorsConstraint(to: self, edgeInsets: .init(top: 12, left: 10, bottom: 12, right: 10)),
            stackView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2),
//            imageView.widthAnchor.constraint(equalToConstant: 50),
//            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: DappButtonViewModel) {
        self.viewModel = viewModel
        
        if isEnabled {
            imageView.image = viewModel.imageForEnabledMode
        } else {
            imageView.image = viewModel.imageForDisabledMode
        }

        label.font = viewModel.font
        label.textColor = viewModel.textColor
        label.text = viewModel.title
        layer.cornerRadius = 12
        layer.borderWidth = 1
        backgroundColor = UIColor.white.withAlphaComponent(0.1)
        layer.borderColor  = UIColor.clear.cgColor
    }
}
