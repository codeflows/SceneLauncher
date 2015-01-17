import UIKit

let CellId = "PlaylistCell"

class PlaylistViewController: UICollectionViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  let osc = OSCService()
  let dataSource = PlaylistDataSource()
  let trackService: TrackService
  
  // MARK: UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView!.backgroundColor = UIColor.whiteColor()
  }
  
  // MARK: UICollectionViewDelegate
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let track = dataSource.tracks[indexPath.indexAtPosition(1)]
    println("TODO play track \(track)")
  }
  
  // MARK: UICollectionViewDelegateFlowLayout
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSize(width: collectionView.bounds.width, height: 100)
  }
  
  // MARK: Init & dealloc
  
  override init() {
    trackService = AbletonTrackService(osc: osc)
    
    super.init(collectionViewLayout: UICollectionViewFlowLayout())
    collectionView!.registerClass(PlaylistCell.self, forCellWithReuseIdentifier: CellId)
    collectionView!.dataSource = dataSource
    
    trackService.listTracks { tracks in
      self.dataSource.tracks = tracks
      self.collectionView!.reloadData()
    }
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

