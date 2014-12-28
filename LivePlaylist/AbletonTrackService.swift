class AbletonTrackService : NSObject, TrackService {
  let osc = OSCService()
  
  func listTracks(callback: ([String]) -> ()) {
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
    osc.sendMessage(message)
    
    osc.incomingMessagesSignal
      .take(1)
      .map { [$0.address] }
      .observe(callback)
  }
}

