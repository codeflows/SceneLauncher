import Foundation
import ReactiveCocoa
import LlamaKit

class OSCService : NSObject, OSCServerDelegate {
  private let client = OSCClient()
  private let localServer = OSCServer()
  private let incomingMessagesSink: SinkOf<Event<OSCMessage, NoError>>

  let incomingMessagesSignal: Signal<OSCMessage, NoError>
  
  init(systemSignals: SystemSignals) {
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

    serverAddressSignal
      |> combineLatestWith(systemSignals.applicationDidBecomeActiveSignal)
      |> start(
        next: { tuple in
          NSLog("[OSCService] Either we woke up or the server address changed; will make sure local server is running, and registering with Ableton at \(tuple.0)")
          self.startLocalServerIfNecessary()
          self.registerWithLiveOSC()
        },
        error: { error in () }
      )
    
    systemSignals.applicationWillResignSignal.observe(next: { self.localServer.stop() })
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

  // TODO rewrite
  func handleDisconnect(error: NSError!) {
    NSLog("[OSCService] UDP socket was disconnected, attempting to reconnect")
    //startListeningOnAnyFreeLocalPort()
    //registerWithLiveOSC()
  }
  
  private func startLocalServerIfNecessary() {
    if(localServer.isClosed()) {
      localServer.listen(0)
      NSLog("[OSCService] Started local server on port \(localServer.getPort())")
    } else {
      NSLog("[OSCService] Local server already running at port \(localServer.getPort())")
    }
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