import Foundation
import ReactiveCocoa
import LlamaKit

class OSCService : NSObject, OSCServerDelegate {
  private let client = OSCClient()
  private let localServer = OSCServer()
  private let incomingMessagesSink: SinkOf<Event<OSCMessage, NoError>>

  let incomingMessagesSignal: Signal<OSCMessage, NoError>
  
  init(applicationState: ApplicationState) {
    (incomingMessagesSignal, incomingMessagesSink) = Signal<OSCMessage, NoError>.pipe()

    super.init()
    localServer.delegate = self

    let serverAddressSignal = Settings.serverAddress.producer
      // TODO ignoreNil would be nice
      |> filter { $0 != nil }
      |> map { $0! }
      |> skipRepeats

    let applicationBecameActive = applicationState.active.producer |> filter { $0 }
    let applicationResigned = applicationState.active.producer |> filter { !$0 }
    
    serverAddressSignal
      |> combineLatestWith(applicationBecameActive)
      |> start(
        next: { _ in self.ensureConnected() },
        error: { _ in () }
      )
    
    applicationResigned |> start(next: { _ in self.stopLocalServer() }, error: { _ in () })
  }
  
  func sendMessage(message: OSCMessage) {
    if let serverAddress = Settings.serverAddress.value {
      NSLog("[OSCService] Sending message \(message)")
      client.sendMessage(message, to: "udp://\(serverAddress):9000")
    } else {
      NSLog("[OSCService] WARNING: Server address not configured, not sending message \(message)")
    }
  }
  
  func handleMessage(incomingMessage: OSCMessage!) {
    if let message = incomingMessage {
      if shouldLog(message) {
        NSLog("[OSCService] Received message \(message)")
      }
      incomingMessagesSink.put(Event.Next(Box(message)))
    }
  }
  
  // Try not to flood the device log
  private func shouldLog(message: OSCMessage) -> Bool {
    return message.address != "/live/track/meter" && message.address != "/live/device/param"
  }

  func handleDisconnect(error: NSError!) {
    NSLog("[OSCService] Local UDP server socket was disconnected: Error: \(error)")
  }
  
  // TODO This is currently public so that we can call it when manually refreshing scenes.
  //      Ideally, connections would be automatically kept alive in the background.
  func ensureConnected() {
    NSLog("[OSCService] Ensuring we're able to communicate with Ableton at \(Settings.serverAddress.value)")
    startLocalServerIfNecessary()
    registerWithLiveOSC()
  }
  
  private func startLocalServerIfNecessary() {
    if(localServer.isClosed()) {
      localServer.listen(0)
      NSLog("[OSCService] Started local server on port \(localServer.getPort())")
    } else {
      NSLog("[OSCService] Local server already running at port \(localServer.getPort())")
    }
  }
  
  private func stopLocalServer() {
    localServer.stop()
  }
  
  private func registerWithLiveOSC() {
    sendMessage(OSCMessage(address: "/remix/set_peer", arguments: ["", localServer.getPort()]))
  }
}

extension OSCMessage: Printable {
  override public var description: String {
    return "\(address) \(arguments)"
  }
}