
import UIKit

class TableViewCell2: UITableViewCell {

    @IBOutlet weak var labelMatricula: UILabel!
    @IBOutlet weak var labelNombre: UILabel!
    @IBOutlet weak var labelAsistencias: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
