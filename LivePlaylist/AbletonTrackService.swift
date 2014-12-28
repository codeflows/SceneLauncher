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
    
    // TODO make this time out after an approriate amount of time
    osc.incomingMessagesSignal
      .filter { $0.address == "/live/scenes" }
      .take(1)
      .map { ["You will receive \($0.arguments[0]) scenes"] }
      .observe(callback)
  }
}

