import UIKit

class PlaylistDataSource: NSObject, UICollectionViewDataSource {
  var tracks: [Track] = []
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellId, forIndexPath: indexPath) as PlaylistCell
    cell.titleLabel.text = String(tracks[indexPath.row].name)
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return tracks.count
  }
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
}