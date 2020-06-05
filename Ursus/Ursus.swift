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
        eventSource?.onMessage { id, event, data in
            #warning("Handle messages (pokes and subscribes) here")
            print("onMessage", id, event, data)
        }
        eventSource?.connect()
    }
    
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
