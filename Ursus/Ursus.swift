//
//  Ursus.swift
//  Ursus
//
//  Created by Daniel Clelland on 3/06/20.
//

import Foundation
import Combine
import IKEventSource

public class Ursus {
    
    private var uid: String = "\(Int(Date().timeIntervalSince1970 * 1000))-\(String(format: "%06x", Int.random(in: 0x000000...0xFFFFFF)))"
    
    private var session = URLSession.shared
    
    private lazy var eventSource = EventSource(url: channelURL)
    
    private var _eventID: Int = 1
    
    private var eventID: Int {
        defer {
            _eventID += 1
        }
        return _eventID
    }
    
    public var url: URL
    
    public var code: String
    
    public init(url: URL, code: String) {
        self.url = url
        self.code = code
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

extension Ursus {
    
    public func connect() -> URLSession.DataTaskPublisher {
        let request = URLRequest(
            url: loginURL,
            method: "POST",
            body: "password=\(code)".data(using: .utf8)
        )
        return session.dataTaskPublisher(for: request)
    }
    
    public func connectEventSource() {
        eventSource.onOpen {
            print("onOpen")
        }
        eventSource.onComplete { status, reconnect, error in
            print("onComplete", status, reconnect, error)
        }
        eventSource.onMessage { id, event, data in
            print("onMessage", id, event, data)
        }
        eventSource.connect()
    }
    
    public func poke<JSON: Encodable>(ship: String, app: String, mark: String, json: JSON) throws -> URLSession.DataTaskPublisher {
        let poke = Poke(id: eventID, ship: ship, app: app, mark: mark, json: json)
        let request = URLRequest(
            url: channelURL,
            headers: ["Content-Type": "application/json"],
            method: "PUT",
            body: try JSONEncoder().encode(poke)
        )
        return session.dataTaskPublisher(for: request)
    }
    
    public func subscribe(ship: String, app: String, path: String) throws -> URLSession.DataTaskPublisher {
        let subscription = Subscription(id: eventID, ship: ship, app: app, path: path)
        let request = URLRequest(
            url: channelURL,
            headers: ["Content-Type": "application/json"],
            method: "PUT",
            body: try JSONEncoder().encode(subscription)
        )
        return session.dataTaskPublisher(for: request)
    }
    
}
