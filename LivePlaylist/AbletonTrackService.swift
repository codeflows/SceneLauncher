import ReactiveCocoa

class AbletonTrackService : NSObject, TrackService, OSCServerDelegate {
  let client = OSCClient()
  let server = OSCServer()
  let (incomingMessagesSignal, incomingMessagesSink) = HotSignal<OSCMessage>.pipe()
  var addresses : HotSignal<String>
  
  override init() {
    addresses = incomingMessagesSignal.map { message in message.address }

    super.init()
    server.delegate = self
    server.listen(9001)
    
    incomingMessagesSignal.observe { message in NSLog("All messages: \(message)") }
    
    addresses.observe { address in NSLog("Address \(address)") }
  }
  
  func listTracks() -> [String] {
    // Pseudo-implementation:
    //
    // To get number of scenes (maybe needed so that we know all scenes have arrived)
    // - send /live/scenes
    // - receive /live/scenes (int)
    //
    // To get names of all scenes
    // - send /live/name/scene
    // - receive series of /live/name/scene (int scene, string name)
    
    let message = OSCMessage(address: "/live/scenes", arguments: [])
    client.sendMessage(message!, to: "udp://localhost:9000")
    
    return ["Boom", "Boom", "Boom"]
  }
  
  func handleMessage(incomingMessage: OSCMessage!) {
    if let message = incomingMessage {
      incomingMessagesSink.put(message)
    }
  }
}

extension OSCMessage: Printable {
  public override var description: String {
    return "\(self.address) \(self.arguments)"
  }
}