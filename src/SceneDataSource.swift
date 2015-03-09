import UIKit

class SceneDataSource: NSObject, UICollectionViewDataSource {
  let trackService: TrackService
  var tracks: [Track] = []
  
  init(osc: OSCService) {
    trackService = AbletonTrackService(osc: osc)
  }

  func reloadData(callback: () -> ()) {
    trackService.listTracks { tracks in
      // TODO poor man's error handling
      if let newTracks = tracks {
        self.tracks = newTracks
      }
      callback()
    }
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellId, forIndexPath: indexPath) as SceneCell
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