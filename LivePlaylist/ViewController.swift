import UIKit

class ViewController: UIViewController {
    let label = UILabel()
    let button = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        label.text = "LivePlaylist"
        label.textAlignment = NSTextAlignment.Center
        label.frame = CGRectMake(0, 50, 150, 50)
        view.addSubview(label)
        view.backgroundColor = UIColor.greenColor()
        
        button.addTarget(self, action: "playPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        button.setTitle("Play/Pause", forState: .Normal)
        button.frame = CGRectMake(0, 150, 150, 50)
        button.backgroundColor = UIColor.redColor()
        view.addSubview(button)
    }
    
    func playPressed(sender: UIButton!) {
        NSLog("Boom, sending message to Reaper")
        let client = OSCClient()
        let message = OSCMessage(address: "/play", arguments: [])
        client.sendMessage(message, to: "udp://localhost:9000")
        NSLog("Done sending")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

