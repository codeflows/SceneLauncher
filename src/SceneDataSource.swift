import UIKit

class SceneDataSource: NSObject, UICollectionViewDataSource {
  let sceneService: SceneService
  var scenes: [Scene] = []
  
  init(osc: OSCService) {
    sceneService = AbletonSceneService(osc: osc)
  }

  func reloadData(callback: ScenesCallback) {
    sceneService.listScenes { result in
      switch result {
        case let .Success(scenes): self.scenes = scenes.unbox
        case let .Failure(error): ()
      }
      callback(result)
    }
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