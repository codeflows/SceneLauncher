import ReactiveCocoa

class AbletonTrackService : NSObject, TrackService, OSCServerDelegate {
  let client = OSCClient()
  let server = OSCServer()
  let (incomingMessagesSignal, incomingMessagesSink) = HotSignal<OSCMessage>.pipe()
  
  override init() {
    super.init()
    server.delegate = self
    server.listen(9001)
    
    //incomingMessagesSignal.observe { message in NSLog("All messages: \(message)") }
    
    let meterMessages = incomingMessagesSignal.filter { message in message.address == "/live/return/meter" }
    meterMessages.observe { message in NSLog("Meter message: \(message)") }
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
    
    /*incomingMessagesSignal.take(1).observe { message in
      NSLog("Scene reply: \(message)")
    }*/
    
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