class AbletonTrackService : NSObject, TrackService {
  let osc = OSCService()
  
  func listTracks(callback: ([String]) -> ()) {
    // Pseudo-implementation:
    //
    // To get names of all scenes
    // - send /live/name/scene
    // - receive series of /live/name/scene (int scene, string name)
    
    let message = OSCMessage(address: "/live/scenes", arguments: [])
    osc.sendMessage(message)
    
    // TODO make this time out after an approriate amount of time
    let numberOfScenes =
      osc.incomingMessagesSignal
        .filter { $0.address == "/live/scenes" }
        .take(1)
        .map { $0.arguments[0] }

    numberOfScenes.observe { number in
      NSLog("This project has \(number) scenes")
    }
  }
}

