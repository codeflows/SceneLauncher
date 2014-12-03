import UIKit

class ViewController: UIViewController {
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        label.text = "LivePlaylist"
        label.textAlignment = NSTextAlignment.Center
        label.backgroundColor = UIColor.redColor()
        view.addSubview(label)
        view.backgroundColor = UIColor.greenColor()
    }
    
    override func viewDidLayoutSubviews() {
        label.frame = view.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

