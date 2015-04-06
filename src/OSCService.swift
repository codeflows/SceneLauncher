import Foundation
import ReactiveCocoa
import LlamaKit

class OSCService : NSObject, OSCServerDelegate {
  private let client = OSCClient()
  private let localServer = OSCServer()
  private let incomingMessagesSink: SinkOf<Event<OSCMessage, NoError>>

  let incomingMessagesSignal: Signal<OSCMessage, NoError>
  
  init(applicationState: ApplicationState) {
    let (signal, sink) = Signal<OSCMessage, NoError>.pipe()
    incomingMessagesSignal = signal
    incomingMessagesSink = sink

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
      |> map { $0.0 }
      |> start(
        next: ensureConnected,
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
      NSLog("[OSCService] Received message \(message)")
      incomingMessagesSink.put(Event.Next(Box(message)))
    }
  }

  func handleDisconnect(error: NSError!) {
    NSLog("[OSCService] Local UDP server socket was disconnected: Error: \(error)")
  }
  
  private func ensureConnected(address: String) {
    NSLog("[OSCService] Ensuring we're able to communicate with Ableton at \(address)")
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