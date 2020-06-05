//
//  Ursus.swift
//  Ursus
//
//  Created by Daniel Clelland on 3/06/20.
//

import Foundation
import IKEventSource

#warning("Unify the way these are handled (with Poke, Ack, Subscribe)")

public typealias PokeRequest<JSON: Encodable> = (ship: String, app: String, mark: String, json: JSON)
public typealias PokeResponse = (onSuccess: (Data) -> Void, onFailure: (Error) -> Void)

public typealias SubscribeRequest = (ship: String, app: String, path: String)
public typealias SubscribeResponse = (onError: (Error) -> Void, onEvent: (Data) -> Void, onQuit: () -> Void)

public class Ursus {
    
    private var session = URLSession.shared
    
    private var uid: String = "\(Int(Date().timeIntervalSince1970 * 1000))-\(String(format: "%06x", Int.random(in: 0x000000...0xFFFFFF)))"
    
    private var eventID: Int = 0
    private var eventSource: EventSource? = nil
    
    private var lastEventID: Int = 0
    private var lastAcknowledgedEventID: Int = 0
    #warning("Does this get set anywhere?")
    
    private var outstandingPokes: [Int: PokeResponse] = [:]
    private var outstandingSubscribes: [Int: SubscribeResponse] = [:]
    
    public var url: URL
    public var code: String
    
    public init(url: URL, code: String) {
        self.url = url
        self.code = code
    }
    
}

extension Ursus {
    
    private var nextEventID: Int {
        eventID += 1
        return eventID
    }
    
}

extension Ursus {
    
    private var loginURL: URL {
        return url.appendingPathComponent("/~/login")
    }
    
    private var channelURL: URL {
        return url.appendingPathComponent("/~/channel/\(uid)")
    }
    
}

#warning("Need delete() function")

extension Ursus {
    
    private func sendJSONToChannel<JSON: Encodable>(_ json: JSON) throws {
        var request = URLRequest(url: channelURL)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"

        #warning("Figure out what to do here (`[ack, json]` won't compile)")
//        if (lastEventID == lastAcknowledgedEventID) {
            request.httpBody = try JSONEncoder().encode([json])
            session.dataTask(with: request) { (data, response, error) in
                print("Request completed:", data, response, error)
            }.resume()
//        } else {
//            let ack = Ack(eventID: lastEventID)
//            request.httpBody = try JSONEncoder().encode([ack, json])
//            session.dataTask(with: request) { (data, response, error) in
//                print("Request completed:", data, response, error)
//            }.resume()
//            lastEventID = lastAcknowledgedEventID
//        }
        
        connectIfDisconnected()
    }
    
    private func connectIfDisconnected() {
        guard eventSource == nil else {
            return
        }
        
        eventSource = EventSource(url: channelURL)
        eventSource?.onOpen {
            print("onOpen")
        }
        eventSource?.onComplete { status, reconnect, error in
            #warning("Handle errors here; if error, delete() and init(); setOnChannelError() and onChannelError")
            print("onComplete", status, reconnect, error)
        }
        eventSource?.onMessage { [weak self] id, event, data in
            print("onMessage", id, event, data)
            
            guard let id = id.flatMap(Int.init) else {
                return
            }
            
            guard let data = data?.data(using: .utf8), let message = try? JSONDecoder().decode(Message.self, from: data) else {
                return
            }
            
            #warning("Does channel.js set lastEventId even if nil...?")
            self?.lastEventID = id
            
            print("onMessage", message)
            switch message.response {
            case .poke:
                break
                // if message["ok"] exists
                // self?.outstandingPokes[message["id"]]?.onSuccess()
                // if message["err"] exists
                // self?.outstandingPokes[message["id"]]?.onFailure()
                // then remove outstandingPokes[message["id"]]
            case .subscribe:
                break
            case .diff:
                break
            case .quit:
                break
            }
            
            #warning("Handle messages (pokes and subscribes) here")
        }
        eventSource?.connect()
    }
    
}

struct Message: Decodable {
    
    enum Response: String, Decodable {
        case poke
        case subscribe
        case diff
        case quit
    }
    
    var id: Int
    var response: Response
    var err: String?
    // ok
    // json
    
}

extension Ursus {
    
    #warning("This probably needs a callback; should also call automatically...?")
    
    public func connect(completion: @escaping () -> Void) {
        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        request.httpBody = "password=\(code)".data(using: .utf8)
        
        session.dataTask(with: request) { (data, response, error) in
            print("Connect completed:", data, response, error)
            completion()
        }.resume()
    }
    
    public func poke<JSON: Encodable>(request: PokeRequest<JSON>, response: PokeResponse) throws {
        let id = nextEventID
        let poke = Poke(id: id, ship: request.ship, app: request.app, mark: request.mark, json: request.json)

        outstandingPokes[id] = response
        try sendJSONToChannel(poke)
    }
    
    public func subscribe(request: SubscribeRequest, response: SubscribeResponse) throws {
        let id = nextEventID
        let subscribe = Subscribe(id: id, ship: request.ship, app: request.app, path: request.path)
        
        outstandingSubscribes[id] = response
        try sendJSONToChannel(subscribe)
    }

    #warning("Finish me")
    
    public func unsubscribe() {
        let id = nextEventID
        
    }
    
}
