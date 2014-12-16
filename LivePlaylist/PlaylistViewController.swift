import UIKit

let CellId = "PlaylistCell"

class PlaylistViewController: UICollectionViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, OSCServerDelegate {
    
    let dataSource = PlaylistDataSource()
    let client = OSCClient()
    let server = OSCServer()
   
    // MARK: OSCServerDelegate
    
    func handleMessage(incomingMessage: OSCMessage!) {
        if let message = incomingMessage {
            NSLog("Received OSCMessage %@ %@", message.address, message.arguments)
        }
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView!.backgroundColor = UIColor.whiteColor()
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        NSLog("Boom! Sending message to Live")
        let message = OSCMessage(address: "/live/play", arguments: [])
        client.sendMessage(message!, to: "udp://localhost:9000")
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

        server.delegate = self
        server.listen(9001)
        
        let trackService = AbletonTrackService()
        let tracks = trackService.listTracks()
        NSLog("Tracks are \(tracks)")
        
        NSLog("Querying for scenes")
        let message = OSCMessage(address: "/live/name/scene", arguments: [])
        client.sendMessage(message!, to: "udp://localhost:9000")

    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

