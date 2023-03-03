// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class SeedPhraseContractView: UIView {
     let descriptionLabel = UILabel()
     let button = UIButton()
     var onTapCheck: (() -> Void)?
   private  var isChecked = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
 

    init(
        description: String
    ) {
        super.init(frame: .zero)
        configure()
    }
    
    private func configure(){
        self.layer.borderWidth = 1.0
        self.layer.borderColor = Configuration.Color.Semantic.seedPhraseContractViewBorderColor.cgColor
        self.layer.cornerRadius = 20
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textColor = Configuration.Color.Semantic.defaultTitleText

        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderWidth = 1
        button.layer.borderColor = Configuration.Color.Semantic.seedPhraseButtonViewBorderColor.cgColor
        button.layer.masksToBounds = true
      
        button.addTarget(self, action: #selector(didTapCheckBoxBtn), for: .touchUpInside)
        addSubview(descriptionLabel)
        addSubview(button)
        configureLayOut()
        self.layoutIfNeeded()
        button.layer.cornerRadius = button.frame.width / 2
      
    }
    
    private func configureLayOut(){
        NSLayoutConstraint.activate([
            descriptionLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -10),
            descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            button.heightAnchor.constraint(equalToConstant: 25.0),
            button.widthAnchor.constraint(equalToConstant: 25.0),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            button.centerYAnchor.constraint(equalTo: descriptionLabel.centerYAnchor),
        ])
    }
    
    
    func getToggleStatus() -> Bool {
        return isChecked
    }
    

    @objc func didTapCheckBoxBtn() {
        isChecked = !isChecked
        if (isChecked) {
            button.setBackgroundColor(.lightGray, forState: .normal)
        } else {
            button.setBackgroundColor(UIColor.clear, forState: .normal)
        }
        onTapCheck?()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
}


