// TODO jari: why do I need this import? why is it not needed in the example?
import UIKit

class PlaylistCell: UICollectionViewCell {
    let titleLabel = UILabel()

    override func layoutSubviews() {
        titleLabel.frame = self.contentView.bounds
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