import UIKit

let CellId = "PlaylistCell"

class PlaylistViewController: UICollectionViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let dataSource = PlaylistDataSource()
   
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView!.backgroundColor = UIColor.whiteColor()
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 100)
    }

    // MARK: Init & dealloc
    
    override init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        collectionView!.registerClass(PlaylistCell.self, forCellWithReuseIdentifier: CellId)
        collectionView!.dataSource = dataSource
        
        let trackService = AbletonTrackService()
        let tracks = trackService.listTracks()
        NSLog("Tracks are \(tracks)")

    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

