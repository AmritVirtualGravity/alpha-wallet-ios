// Copyright © 2019 Stormbird PTE. LTD.

import Foundation
import UIKit

class SeedPhraseCell: UICollectionViewCell {
    private let sequenceLabel = UILabel()
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        sequenceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sequenceLabel)

        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            sequenceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            sequenceLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            label.leadingAnchor.constraint(equalTo: sequenceLabel.trailingAnchor, constant: 6),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: SeedPhraseCellViewModel) {
        borderColor = Configuration.Color.Semantic.tableViewCellPrimaryFont.withAlphaComponent(0.3)
        borderWidth = 1
        cornerRadius = 7

        if viewModel.sequence != nil {
            sequenceLabel.font = viewModel.sequenceFont
            sequenceLabel.textColor = viewModel.sequenceColor
            sequenceLabel.text = viewModel.sequence
        } else {
            sequenceLabel.text = ""
        }

        label.textAlignment = .center
        label.font = viewModel.font
        label.text = viewModel.word

//        if viewModel.isSelected {
//            contentView.backgroundColor = viewModel.selectedBackgroundColor
//            backgroundColor = viewModel.selectedBackgroundColor
//            label.textColor = viewModel.selectedTextColor
//        } else {
//            contentView.backgroundColor = viewModel.backgroundColor
//            backgroundColor = viewModel.backgroundColor
//            label.textColor = viewModel.textColor
//        }
        
        label.textColor = Configuration.Color.Semantic.tableViewCellPrimaryFont
    }
}
