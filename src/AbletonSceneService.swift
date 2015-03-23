import ReactiveCocoa
import LlamaKit

class AbletonSceneService : NSObject, SceneService {
  let osc : OSCService
  
  init(osc: OSCService) {
    self.osc = osc
  }
  
  func listScenes(callback: ScenesCallback) {
    // TODO currently many requests might be waiting at the same time
    // TODO LiveOsc(?) fails if Scene name contains Unicode characters and returns /remix/error -> short-circuit signal here
    // TODO reliable mechanism for pinging if the server is still reachable
    // TODO refactor: abstraction for sending and receiving message of the same address (e.g. both cases below)

    let numberOfScenes : Signal<Int, NSError> =
      osc.incomingMessagesSignal
        |> filter { $0.address == "/live/scenes" }
        |> take(1)
        |> map { $0.arguments[0] as Int }
        |> timeoutWithError(NSError(), afterInterval: 5, onScheduler: QueueScheduler.mainQueueScheduler)

    osc.sendMessage(OSCMessage(address: "/live/scenes", arguments: []))
    
    // TODO really, we'd like to flatMap the Signal(numberOfScenes) to Signal([Scene]) and timeout in one place
    numberOfScenes.observe(next: { expectedNumberOfScenes in
      self.handleSceneListResponse(callback, expectedNumberOfScenes: expectedNumberOfScenes)
      self.osc.sendMessage(OSCMessage(address: "/live/name/scene", arguments: []))
    }, error: { err in
      // TODO
      println("Timeout in number of scenes response")
      callback(failure(err))
    })
  }
  
  private func handleSceneListResponse(callback: ScenesCallback, expectedNumberOfScenes: Int) {
    let scenesSignal : Signal<[Scene], NSError> =
      osc.incomingMessagesSignal
        // TODO this should be done in every request-response case
        |> try { $0.address == "/remix/error" ? failure(NSError()) : success() }

        |> filter { $0.address == "/live/name/scene" }
        |> take(expectedNumberOfScenes)
        |> map { Scene(order: $0.arguments[0] as Int, name: $0.arguments[1] as String) }
        |> collect
        |> timeoutWithError(NSError(), afterInterval: 5, onScheduler: QueueScheduler.mainQueueScheduler)
    
    let sortedScenesSignal = scenesSignal |> map { scenes in
      scenes.sorted({$0.order < $1.order})
    }
    
    // TODO handle UI thread stuff in the view controller
    let tempSignal = sortedScenesSignal |> observeOn(UIScheduler())
    tempSignal.observe(
      next: { scenes in callback(success(scenes)) },
      error: { err in println("Timeout in scene list response"); callback(failure(err)) }
    )
  }
}

