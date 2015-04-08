import UIKit
import ReactiveCocoa

class SceneDataSource: NSObject, UICollectionViewDataSource {
  let sceneService: SceneService
  var scenes: [Scene] = []
  
  init(osc: OSCService) {
    sceneService = AbletonSceneService(osc: osc)
  }

  func reloadData(callback: (SceneLoadingError?) -> ()) {
    sceneService.listScenes() |> start(
      next: { scenes in
        self.scenes = scenes
        callback(nil)
      },
      error: { error in callback(error) }
    )
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellId, forIndexPath: indexPath) as! SceneCell
    cell.titleLabel.text = String(scenes[indexPath.row].name)
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return scenes.count
  }
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
}