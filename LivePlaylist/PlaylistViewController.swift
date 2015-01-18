import UIKit

let CellId = "PlaylistCell"

class PlaylistViewController: UICollectionViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  let osc: OSCService
  let dataSource: PlaylistDataSource
  
  // MARK: UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView!.backgroundColor = UIColor.whiteColor()
  }
  
  // MARK: UICollectionViewDelegate
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let track = dataSource.tracks[indexPath.indexAtPosition(1)]
    osc.sendMessage(OSCMessage(address: "/live/play/scene", arguments: [track.order]))
  }
  
  // MARK: UICollectionViewDelegateFlowLayout
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSize(width: collectionView.bounds.width, height: 100)
  }
  
  // MARK: Init & dealloc
  
  override init() {
    osc = OSCService()
    dataSource = PlaylistDataSource(osc: osc)
    
    super.init(collectionViewLayout: UICollectionViewFlowLayout())
    collectionView!.registerClass(PlaylistCell.self, forCellWithReuseIdentifier: CellId)
    collectionView!.dataSource = dataSource
    
    dataSource.reloadData() {
      self.collectionView!.reloadData()
    }
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

