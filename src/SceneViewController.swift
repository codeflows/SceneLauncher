import UIKit
import ReactiveCocoa

let CellId = "SceneCell"

class SceneViewController: UICollectionViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  let osc: OSCService
  let dataSource: SceneDataSource
  let refreshControl: UIRefreshControl
  let helpMessageView: UITextView
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView!.backgroundColor = UIColor.whiteColor()
    // TODO autolayout
    helpMessageView.frame = CGRect(x: UIConstants.margin, y: UIConstants.margin, width: collectionView!.bounds.width - 2 * UIConstants.margin, height: collectionView!.bounds.height)
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
    return CGSize(width: collectionView.bounds.width, height: 58)
  }

  private let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: UIConstants.controlsHeight, right: 0)
  
  func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    return sectionInsets
  }

  init(applicationContext: ApplicationContext) {
    self.osc = applicationContext.oscService
    dataSource = SceneDataSource(osc: osc)
    refreshControl = UIRefreshControl()
    helpMessageView = UITextView()
    
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0

    super.init(collectionViewLayout: layout)

    collectionView!.registerClass(SceneCell.self, forCellWithReuseIdentifier: CellId)
    collectionView!.dataSource = dataSource
   
    refreshControl.addTarget(self, action: "refreshScenesManually", forControlEvents: .ValueChanged)
    collectionView!.addSubview(refreshControl)
    collectionView!.alwaysBounceVertical = true
    
    collectionView!.addSubview(helpMessageView)
    helpMessageView.font = UIFont(name: UIConstants.fontName, size: 20)
    helpMessageView.scrollEnabled = false
    helpMessageView.editable = false
    
    // TODO jari: move somewhere else
    let sceneNumberChanges: Signal<Int, NoError> =
      osc.incomingMessagesSignal
        |> filter { $0.address == "/live/scene" }
        // This seems to be off-by-one??!
        |> map { ($0.arguments[0] as Int) - 1 }
        |> observeOn(UIScheduler())

    sceneNumberChanges.observe(next: { sceneNumber in
      for (index, scene) in enumerate(self.dataSource.scenes) {
        if(scene.order == sceneNumber) {
          let p = NSIndexPath(forRow: index, inSection: 0)
          self.collectionView?.selectItemAtIndexPath(p, animated: true, scrollPosition: UICollectionViewScrollPosition.CenteredVertically)
        }
      }
    })
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func refreshScenesManually() {
    // TODO jari: inelegant "error handling" here
    //
    // Messages are lost due to UDP dropouts etc, so make sure
    // LiveOSC knows our address whenever the user manually refreshes the list
    //
    // A much more robust way would be to e.g.
    // 1) broadcast our new address to LiveOSC
    // 2) ping for a response from the server, wait for an answer
    // 3) possibly retry a couple of times
    // 4) only then proceed with sending any other messages
    if let serverAddress = Settings.serverAddress.value {
      osc.reconfigureServerAddress(serverAddress)
    }
    refreshScenes()
  }
  
  private func refreshScenesAutomatically() {
    refreshControl.beginRefreshing()
    // Hack to make indicator visible: http://stackoverflow.com/questions/17930730/uirefreshcontrol-on-viewdidload
    collectionView?.contentOffset = CGPointMake(0, -refreshControl.frame.size.height)
    refreshScenes()
  }

  private func refreshScenes() {
    dataSource.reloadData() { result in
      if let error = result.error {
        self.handleError(error)
      } else {
        self.helpMessageView.hidden = true
      }
      self.collectionView!.reloadData()
      self.refreshControl.endRefreshing()
    }
  }
  
  private func handleError(error: SceneLoadingError) {
    let scenesHaveBeenPreviouslyLoaded = dataSource.scenes.count > 0
    
    switch error {
      case let .NoAddressConfigured:
        if scenesHaveBeenPreviouslyLoaded {
          showAlert("No address configured", message: "Please go to settings and configure your Ableton Live server address")
        }
      case let .Unknown: showAlert("Unknown error", message: "Could not load scenes")
      case let .LiveOsc(message): showAlert("LiveOSC error", message: message)
      case let .Timeout: showAlert("Could not load scenes", message: "Please make sure Ableton Live is running and the server address is correct in settings")
    }

    if !scenesHaveBeenPreviouslyLoaded {
      helpMessageView.hidden = false
      switch error {
        case let .NoAddressConfigured:
          helpMessageView.text = "Welcome to SceneLauncher!\n\nTo start, please click the settings icon below and configure your Ableton Live server address."
        default:
          helpMessageView.text = "Scenes could not be loaded. Please make sure Ableton Live is running and the server address is correct in settings.\n\nTo try loading the scenes again, simply pull down to refresh."
      }
    }
  }
  
  private func showAlert(title: String, message: String) {
    let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
    alert.show()
  }
}

