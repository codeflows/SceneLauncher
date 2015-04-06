import ReactiveCocoa
import LlamaKit

class AbletonSceneService : NSObject, SceneService {
  let osc : OSCService
  
  init(osc: OSCService) {
    self.osc = osc
  }
  
  func listScenes(callback: ScenesCallback) {
    // TODO currently many requests might be waiting at the same time
    // TODO reliable mechanism for pinging if the server is still reachable
    // TODO refactor: abstraction for sending and receiving message of the same address (e.g. both cases below)

    if Settings.serverAddress.value == nil {
      callback(failure(.NoAddressConfigured))
      return
    }
    
    let numberOfScenes : Signal<Int, SceneLoadingError> =
      incomingMessages(timeout: 2)
        |> filter { $0.address == "/live/scenes" }
        |> take(1)
        |> map { $0.arguments[0] as Int }

    // TODO really, we'd like to flatMap the Signal(numberOfScenes) to Signal([Scene]) and timeout in one place
    numberOfScenes.observe(next: { expectedNumberOfScenes in
      self.handleSceneListResponse(callback, expectedNumberOfScenes: expectedNumberOfScenes)
      self.osc.sendMessage(OSCMessage(address: "/live/name/scene", arguments: []))
    }, error: { err in
      callback(failure(err))
    })

    osc.sendMessage(OSCMessage(address: "/live/scenes", arguments: []))
  }
  
  private func handleSceneListResponse(callback: ScenesCallback, expectedNumberOfScenes: Int) {
    let scenesSignal : Signal<[Scene], SceneLoadingError> =
      incomingMessages(timeout: 3)
        |> filter { $0.address == "/live/name/scene" }
        |> take(expectedNumberOfScenes)
        |> map { Scene(order: $0.arguments[0] as Int, name: self.trim($0.arguments[1] as String)) }
        |> collect
    
    let sortedScenesSignal = scenesSignal |> map { scenes in
      scenes.sorted({$0.order < $1.order})
    }
    
    // TODO handle UI thread stuff in the view controller
    let tempSignal = sortedScenesSignal |> observeOn(UIScheduler())
    tempSignal.observe(
      next: { scenes in callback(success(scenes)) },
      error: { err in callback(failure(err)) }
    )
  }
  
  private func incomingMessages(#timeout: NSTimeInterval) -> Signal<OSCMessage, SceneLoadingError> {
    return osc.incomingMessagesSignal
      |> mapError { _ in .Unknown }
      |> try { message in
        if(message.address == "/remix/error") {
          return failure(.LiveOsc(self.parseLiveOSCErrorReason(message)))
        }
        return success()
      }
      |> timeoutWithError(.Timeout, afterInterval: timeout, onScheduler: QueueScheduler.mainQueueScheduler)
  }
  
  private func parseLiveOSCErrorReason(message: OSCMessage) -> String {
    if(message.arguments.count == 1 && message.arguments[0] is String) {
      let errorMessage = message.arguments[0] as String
      
      if errorMessage.rangeOfString("UnicodeEncodeError") != nil {
        return "Unicode error: LiveOSC doesn't support special unicode characters, please check your scene names."
      }
    }
    return "Unknown error from LiveOSC"
  }
  
  // Scenes are named " 1" etc by default
  private func trim(str: String) -> String {
    return str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
  }
}

