import UIKit
import Cartography

class PlaylistCell: UICollectionViewCell {
  let titleLabel = UILabel()
  
  override func layoutSubviews() {
    titleLabel.frame = self.contentView.bounds
    // FIXME
    layout(titleLabel) { label in
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.backgroundColor = UIColor.greenColor()
    self.contentView.addSubview(titleLabel)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }  
}