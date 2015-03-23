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
    // TODO if server address changes (note: ACTUALLY changes from previous) -> should discard any ongoing refresh
    if(!refreshControl.refreshing) {
      refreshScenesAutomatically()
    }
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let scene = dataSource.scenes[indexPath.indexAtPosition(1)]
    osc.sendMessage(OSCMessage(address: "/live/play/scene", arguments: [scene.order]))
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
   
    refreshControl.addTarget(self, action: "refreshScenes", forControlEvents: .ValueChanged)
    collectionView!.addSubview(refreshControl)
    collectionView!.alwaysBounceVertical = true
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func refreshScenesAutomatically() {
    refreshControl.beginRefreshing()
    // Hack to make indicator visible: http://stackoverflow.com/questions/17930730/uirefreshcontrol-on-viewdidload
    collectionView?.contentOffset = CGPointMake(0, -refreshControl.frame.size.height)
    refreshScenes()
  }

  func refreshScenes() {
    dataSource.reloadData() { result in
      if let error = result.error {
        let alert = UIAlertView(title: "Timeout loading scenes", message: "Make sure the Ableton Live server address is correct in settings", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
      }
      self.collectionView!.reloadData()
      self.refreshControl.endRefreshing()
    }
  }
}

