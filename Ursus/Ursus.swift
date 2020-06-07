//
//  Ursus.swift
//  Ursus
//
//  Created by Daniel Clelland on 3/06/20.
//

import Foundation
import Alamofire
import IKEventSource

#warning("Unify the way these are handled (with Poke, Ack, Subscribe)")

public typealias PokeResponse = (onSuccess: (Data) -> Void, onFailure: (Error) -> Void)

public typealias SubscribeResponse = (onError: (Error) -> Void, onEvent: (Data) -> Void, onQuit: () -> Void)

public class Ursus {
    
    private var session: Session = .default
    private var eventSource: EventSource? = nil
    
    private var outstandingPokes: [Int: PokeResponse] = [:]
    private var outstandingSubscribes: [Int: SubscribeResponse] = [:]
    
    private var uid: String = "\(Int(Date().timeIntervalSince1970 * 1000))-\(String(format: "%06x", Int.random(in: 0x000000...0xFFFFFF)))"
    
    private var requestID: Int = 0
    private var nextRequestID: Int {
        requestID += 1
        return requestID
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
    
    @discardableResult public func loginRequest() -> DataRequest {
        return session.request(loginURL, method: .post, parameters: ["password": code], encoder: URLEncodedFormParameterEncoder.default)
    }
    
    @discardableResult public func channelRequest<Parameters: Encodable>(_ parameters: Parameters) -> DataRequest {
        defer { connectIfDisconnected() }
        return session.request(channelURL, method: .put, parameters: [parameters], encoder: JSONParameterEncoder.default)
    }
    
}

extension Ursus {
    
    private func connectIfDisconnected() {
        guard eventSource == nil else {
            return
        }
        
        eventSource = EventSource(url: channelURL)
        eventSource?.onMessage { [weak self] id, event, data in
            print("onMessage", id, event, data)
            
            guard let id = id.flatMap(Int.init) else {
                return
            }
            
            guard let data = data?.data(using: .utf8), let message = try? JSONDecoder().decode(Message.self, from: data) else {
                return
            }
            
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
        eventSource?.onComplete { [weak self] status, reconnect, error in
            #warning("Handle errors here; if error, delete() and init(); setOnChannelError() and onChannelError")
            print("onComplete", status, reconnect, error)
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
    
    @discardableResult public func ackRequest(eventID: Int) -> DataRequest {
        let request = AckRequest(eventID: eventID)
        return channelRequest(request)
    }
    
    @discardableResult public func pokeRequest<JSON: Encodable>(ship: String, app: String, mark: String, json: JSON, pokeResponse: PokeResponse) -> DataRequest {
        let request = PokeRequest(id: nextRequestID, ship: ship, app: app, mark: mark, json: json)
        return channelRequest(request).response { [weak self] response in
            if case .success = response.result {
                self?.outstandingPokes[request.id] = pokeResponse
            }
        }
    }
    
    @discardableResult public func subscribeRequest(ship: String, app: String, path: String, subscribeResponse: SubscribeResponse) -> DataRequest {
        let request = SubscribeRequest(id: nextRequestID, ship: ship, app: app, path: path)
        return channelRequest(request).response { [weak self] response in
            if case .success = response.result {
                self?.outstandingSubscribes[request.id] = subscribeResponse
            }
        }
    }
    
    @discardableResult public func unsubscribeRequest(subscriptionID: Int) -> DataRequest {
        let request = UnsubscribeRequest(id: nextRequestID, subscriptionID: subscriptionID)
        return channelRequest(request)
    }
    
    @discardableResult public func deleteRequest() -> DataRequest {
        let request = DeleteRequest()
        return channelRequest(request)
    }
    
}
