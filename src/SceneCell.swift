import UIKit
import Cartography

class SceneCell: UICollectionViewCell {
  let titleLabel = UILabel()
  let purpleColor,
      cellBackgroundColor,
      cellSelectedBackgroundColor: UIColor
  
  override var selected: Bool {
    get {
      return super.selected
    }
    set(h) {
      super.selected = h
      self.toggleBackgroundColor(h)
    }
  }
  
  override init(frame: CGRect) {
    purpleColor = UIColor(red: 169/255.0, green: 31/255.0, blue: 199/255.0, alpha: 1.0)
    cellBackgroundColor = purpleColor.colorWithAlphaComponent(0.1)
    cellSelectedBackgroundColor = purpleColor.colorWithAlphaComponent(0.4)
    
    super.init(frame: frame)
    
    self.contentView.addSubview(titleLabel)
    toggleBackgroundColor(false)

    var bottomBorder = CALayer()
    bottomBorder.backgroundColor = purpleColor.colorWithAlphaComponent(0.7).CGColor
    bottomBorder.frame = CGRect(x: 0, y: self.contentView.frame.height - 0.5, width: self.contentView.frame.width, height: 0.5)
    self.contentView.layer.addSublayer(bottomBorder)
    
    titleLabel.font = UIFont(name: UIConstants.fontName, size: 20)
    titleLabel.textColor = UIColor.blackColor()

    layout(titleLabel) { titleLabel in
      titleLabel.height == titleLabel.superview!.height
      titleLabel.left == titleLabel.superview!.left + UIConstants.margin
      titleLabel.right == titleLabel.superview!.right - UIConstants.margin
    }
  }
  
  private func toggleBackgroundColor(selected: Bool) {
    self.contentView.backgroundColor = selected ?
      cellSelectedBackgroundColor :
      cellBackgroundColor
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }  
}