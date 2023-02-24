
import Foundation

struct Lif3NewsListModel: Codable {
    // MARK: Properties

    var title,subtitle, text, image, url: String?
    
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case subtitle = "subtitle"
        case text = "text"
        case image = "image"
        case url = "url"
    }
}
