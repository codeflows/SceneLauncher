import ReactiveCocoa

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
    // TODO LiveOsc(?) fails if Scene name contains Unicode characters and returns /remix/error
    let numberOfScenes : HotSignal<Int> =
      osc.incomingMessagesSignal
        .filter { $0.address == "/live/scenes" }
        .take(1)
        .map { $0.arguments[0] as Int }
    
    /*let x : HotSignal<OSCMessage> = numberOfScenes.mergeMap { n in
      NSLog("BOOM! Getting names for \(n) scenes")
      osc.sendMessage(OSCMessage(address: "/live/name/scene", arguments: []))
      return osc.incomingMessagesSignal
        .filter { $0.address == "/live/name/scene" }
        .observe { NSLog("  Got scene #\($0.arguments[0]): \($0.arguments[1])") }
    }*/
  }
}

