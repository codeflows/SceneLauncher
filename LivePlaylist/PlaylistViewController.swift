import UIKit

let CellId = "PlaylistCell"

class PlaylistViewController: UICollectionViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  let osc: OSCService
  let dataSource: PlaylistDataSource
  let refreshControl: UIRefreshControl
  
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
    return CGSize(width: collectionView.bounds.width, height: 40)
  }
  
  // MARK: Init & dealloc
  
  override init() {
    osc = OSCService()
    dataSource = PlaylistDataSource(osc: osc)
    refreshControl = UIRefreshControl()
    
    let layout = UICollectionViewFlowLayout()
    super.init(collectionViewLayout: layout)
    layout.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0)
    
    collectionView!.registerClass(PlaylistCell.self, forCellWithReuseIdentifier: CellId)
    collectionView!.dataSource = dataSource
   
    refreshControl.addTarget(self, action: "refreshTracks", forControlEvents: .ValueChanged)
    collectionView!.addSubview(refreshControl)
    collectionView!.alwaysBounceVertical = true
    
    refreshTracks()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: UIRefreshControl delegate

  func refreshTracks() {
    dataSource.reloadData() {
      self.collectionView!.reloadData()
      self.refreshControl.endRefreshing()
    }
  }
}

