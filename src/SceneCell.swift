import UIKit
import Cartography

class SceneCell: UICollectionViewCell {
  let titleLabel = UILabel()
  let purpleColor = UIColor(red: 169/255.0, green: 31/255.0, blue: 199/255.0, alpha: 1.0)

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.contentView.addSubview(titleLabel)

    self.contentView.backgroundColor = purpleColor.colorWithAlphaComponent(0.1)

    var bottomBorder = CALayer()
    bottomBorder.backgroundColor = purpleColor.colorWithAlphaComponent(0.7).CGColor
    bottomBorder.frame = CGRect(x: 0, y: self.contentView.frame.height - 0.5, width: self.contentView.frame.width, height: 0.5)
    self.contentView.layer.addSublayer(bottomBorder)
    
    titleLabel.font = UIFont(name: UIConstants.fontName, size: 18)
    titleLabel.textColor = UIColor.blackColor()

    layout(titleLabel) { titleLabel in
      titleLabel.height == titleLabel.superview!.height
      titleLabel.left == titleLabel.superview!.left + UIConstants.margin
      titleLabel.right == titleLabel.superview!.right - UIConstants.margin
    }
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }  
}