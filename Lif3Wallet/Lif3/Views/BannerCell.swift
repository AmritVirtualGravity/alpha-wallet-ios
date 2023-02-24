
import UIKit

class BannerCell: UICollectionViewCell, NibReusable {

    // IBOutLet
  
    @IBOutlet weak var imgNews: UIImageView! {
        didSet {
            imgNews.layer.cornerRadius = 12
            imgNews.clipsToBounds = true
            imgNews.contentMode = .scaleToFill
        }
    }
    
    @IBOutlet weak var lblNewsSubtitle: UILabel!
    
    @IBOutlet weak var lblNewsTitle: UILabel!
    
    @IBOutlet weak var heightButton: NSLayoutConstraint!
    

    override func layoutSubviews() {
        super.layoutSubviews()

    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func loadCell(_ news: Lif3NewsListModel) {
        if let img = news.image {
            if let url = URL(string: img){
                self.imgNews.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder.png"))
            }
        }
        if let title = news.title {
            lblNewsTitle.text = title
        }
        if let subtitle = news.subtitle {
            lblNewsSubtitle.text = subtitle
        }
       
    }
    
   

}
