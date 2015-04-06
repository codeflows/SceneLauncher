import Foundation
import ReactiveCocoa
import LlamaKit

class OSCService : NSObject, OSCServerDelegate {
  private let client = OSCClient()
  private let localServer = OSCServer()
  private let incomingMessagesSink : SinkOf<Event<OSCMessage, NoError>>

  let incomingMessagesSignal : Signal<OSCMessage, NoError>

  override init() {
    let (signal, sink) = Signal<OSCMessage, NoError>.pipe()
    incomingMessagesSignal = signal
    incomingMessagesSink = sink

    super.init()
    localServer.delegate = self

    startLocalServer()

    Settings.serverAddress.producer
      // TODO ignoreNil would be nice
      |> filter { $0 != nil }
      |> map { $0! }
      |> skipRepeats
      |> start(
        next: { address in
          NSLog("[OSCService] Server address is now \(address), registering with LiveOSC")
          self.registerWithLiveOSC()
        },
        error: { error in () }
      )

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResign", name: UIApplicationWillResignActiveNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
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

  func applicationWillResign() {
    NSLog("[OSCService] Application will resign, stopping OSC server")
    localServer.stop()
  }

  func applicationDidBecomeActive() {
    NSLog("[OSCService] Application became active")
  }
  
  // TODO rewrite
  func handleDisconnect(error: NSError!) {
    NSLog("[OSCService] UDP socket was disconnected, attempting to reconnect")
    //startListeningOnAnyFreeLocalPort()
    //registerWithLiveOSC()
  }
  
  private func startLocalServer() {
    localServer.listen(0)
    NSLog("[OSCService] Started listening on local port \(localServer.getPort())")
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