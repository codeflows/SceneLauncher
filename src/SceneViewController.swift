import UIKit

let CellId = "SceneCell"

class SceneViewController: UICollectionViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  let osc: OSCService
  let dataSource: SceneDataSource
  let refreshControl: UIRefreshControl
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView!.backgroundColor = UIColor.whiteColor()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    refreshTracksAutomatically()
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let track = dataSource.tracks[indexPath.indexAtPosition(1)]
    osc.sendMessage(OSCMessage(address: "/live/play/scene", arguments: [track.order]))
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSize(width: collectionView.bounds.width, height: 40)
  }
  
  init(applicationContext: ApplicationContext) {
    self.osc = applicationContext.oscService
    dataSource = SceneDataSource(osc: osc)
    refreshControl = UIRefreshControl()
    
    let layout = UICollectionViewFlowLayout()
    super.init(collectionViewLayout: layout)
    
    collectionView!.registerClass(SceneCell.self, forCellWithReuseIdentifier: CellId)
    collectionView!.dataSource = dataSource
   
    refreshControl.addTarget(self, action: "refreshTracks", forControlEvents: .ValueChanged)
    collectionView!.addSubview(refreshControl)
    collectionView!.alwaysBounceVertical = true
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func refreshTracksAutomatically() {
    refreshControl.beginRefreshing()
    // Hack to make indicator visible: http://stackoverflow.com/questions/17930730/uirefreshcontrol-on-viewdidload
    collectionView?.contentOffset = CGPointMake(0, -refreshControl.frame.size.height)
    refreshTracks()
  }

  func refreshTracks() {
    dataSource.reloadData() {
      self.collectionView!.reloadData()
      self.refreshControl.endRefreshing()
    }
  }
}

