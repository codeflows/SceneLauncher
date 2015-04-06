import Foundation
import ReactiveCocoa
import LlamaKit

class OSCService : NSObject, OSCServerDelegate {
  private let client = OSCClient()
  private let server = OSCServer()
  private let incomingMessagesSink : SinkOf<Event<OSCMessage, NoError>>

  let incomingMessagesSignal : Signal<OSCMessage, NoError>

  override init() {
    let (signal, sink) = Signal<OSCMessage, NoError>.pipe()
    incomingMessagesSignal = signal
    incomingMessagesSink = sink

    super.init()
    server.delegate = self

    startListeningOnAnyFreeLocalPort()
    
    // TODO ignoreNil would be nice
    Settings.serverAddress.producer |> filter { $0 != nil } |> map { $0! } |> start(next: { address in
      NSLog("[OSCService] Server address is now \(address), registering with LiveOSC")
      self.registerWithLiveOSC()
    }, error: { error in () })
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
  
  private func startListeningOnAnyFreeLocalPort() {
    server.listen(0)
    NSLog("[OSCService] Started listening on local port \(server.getPort())")
  }
  
  private func registerWithLiveOSC() {
    sendMessage(OSCMessage(address: "/remix/set_peer", arguments: ["", server.getPort()]))
  }
}

extension OSCMessage: Printable {
  override public var description: String {
    return "\(address) \(arguments)"
  }
}