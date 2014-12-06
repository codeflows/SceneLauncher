import UIKit

class ViewController: UIViewController, OSCServerDelegate {
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        label.text = "LivePlaylist"
        label.textAlignment = NSTextAlignment.Center
        label.backgroundColor = UIColor.redColor()
        view.addSubview(label)
        view.backgroundColor = UIColor.greenColor()
        
        // TODO temporary
        let server = OSCServer()
        server.delegate = self
        server.listen(8000)
        
        NSLog("Boom, sending message to Reaper")
        let client = OSCClient()
        let message = OSCMessage(address: "/play", arguments: [])
        client.sendMessage(message, to: "udp://localhost:9000")
        NSLog("Done sending")
    }
    
    func handleMessage(message: OSCMessage) {
        NSLog("Received message \(message)!")
    }
    
    override func viewDidLayoutSubviews() {
        label.frame = view.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

