
import UIKit;
import Foundation

class WoningTableViewCell : UITableViewCell
{
    
    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var streetName: UILabel!
    
    @IBOutlet weak var cityName: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    var imageURL: String?
    
    @IBOutlet var favoriteButton: LikeButton!
    
}