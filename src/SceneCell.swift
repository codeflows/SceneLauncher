import UIKit

class SceneCell: UICollectionViewCell {
  let titleLabel = UILabel()
  let purpleColor = UIColor(red: 169/255.0, green: 31/255.0, blue: 199/255.0, alpha: 1.0)

  override func layoutSubviews() {
    titleLabel.frame = self.contentView.bounds
    titleLabel.font = UIFont(name: UIConstants.fontName, size: 18)
    titleLabel.backgroundColor = purpleColor
    titleLabel.textColor = UIColor.whiteColor()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.contentView.addSubview(titleLabel)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }  
}