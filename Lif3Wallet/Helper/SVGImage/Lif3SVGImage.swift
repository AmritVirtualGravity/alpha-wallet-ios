//
//  SVGImage.swift
//  Pools
//
//  Created by Amrit Duwal on 4/13/23.
//

import UIKit
import SDWebImage

@IBDesignable class Lif3SVGImage: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var imageUrl: String = "" {
        didSet {
            setImage(url: imageUrl)
        }
    }
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var svgImageView: UIImageView!
    
    override init(frame: CGRect) { //for using CustomView in Code
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) { // for using CustomView in IB
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        loadXib()
    }
    
    // MARK: load xib
    private func loadXib() {
        view = loadFromNib(nibName: "Lif3SVGImage")
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = self.bounds
        addSubview(view)
    }
    

    private func setImage(url: String) {
        if let imageUrl = URL(string: "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/Steps.svg") {
//            self.svgImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "logo"))
            self.svgImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "icons-tokens-a-lend"))
        }
    }
    
}
