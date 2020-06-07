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

public typealias PokeCallbacks = (onSuccess: (Data) -> Void, onFailure: (Error) -> Void)

public typealias SubscribeCallbacks = (onError: (Error) -> Void, onEvent: (Data) -> Void, onQuit: () -> Void)

public class Ursus {
    
    private var session: Session = .default
    private var eventSource: EventSource? = nil
    
    private var outstandingPokes: [Int: PokeCallbacks] = [:]
    private var outstandingSubscribes: [Int: SubscribeCallbacks] = [:]
    
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
        connectIfDisconnected()
        return session.request(channelURL, method: .put, parameters: [parameters], encoder: JSONParameterEncoder.default)
    }
    
}

extension Ursus {
    
    private func connectIfDisconnected() {
        guard eventSource == nil else {
            return
        }
        
        eventSource = EventSource(url: channelURL)
        eventSource?.onOpen {
            print("onOpen")
        }
        eventSource?.onMessage { [weak self] id, event, data in
            guard let id = id.flatMap(Int.init) else {
                return
            }
            
            guard let data = data?.data(using: .utf8), let response = try? JSONDecoder().decode(Response.self, from: data) else {
                return
            }
            
            print("onMessage", id, event, response)
            
//            print("onMessage", message)
//            switch message.response {
//            case .poke:
//                break
//                // if message["ok"] exists
//                // self?.outstandingPokes[message["id"]]?.onSuccess()
//                // if message["err"] exists
//                // self?.outstandingPokes[message["id"]]?.onFailure()
//                // then remove outstandingPokes[message["id"]]
//            case .subscribe:
//                break
//            case .diff:
//                break
//            case .quit:
//                break
//            }
            
            #warning("Handle messages (pokes and subscribes) here")
        }
        eventSource?.onComplete { [weak self] status, reconnect, error in
            #warning("Handle errors here; if error, delete() and init(); setOnChannelError() and onChannelError")
            print("onComplete", status, reconnect, error)
        }
        eventSource?.connect()
    }
    
}

enum Response: Decodable {
    
    case poke(PokeResponse)
    case subscribe(SubscribeResponse)
    case diff(DiffResponse)
    case quit(QuitResponse)
    
    enum Response: String, Decodable {
        case poke
        case subscribe
        case diff
        case quit
    }
    
    enum CodingKeys: String, CodingKey {
        case response
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Response.self, forKey: .response) {
        case .poke:
            self = .poke(try PokeResponse(from: decoder))
        case .subscribe:
            self = .subscribe(try SubscribeResponse(from: decoder))
        case .diff:
            self = .diff(try DiffResponse(from: decoder))
        case .quit:
            self = .quit(try QuitResponse(from: decoder))
        }
    }
    
}

extension Ursus {
    
    @discardableResult public func ackRequest(eventID: Int) -> DataRequest {
        let request = AckRequest(eventID: eventID)
        return channelRequest(request)
    }
    
    @discardableResult public func pokeRequest<JSON: Encodable>(ship: String, app: String, mark: String, json: JSON, callbacks: PokeCallbacks) -> DataRequest {
        let request = PokeRequest(id: nextRequestID, ship: ship, app: app, mark: mark, json: json)
        return channelRequest(request).response { [weak self] response in
            if case .success = response.result {
                self?.outstandingPokes[request.id] = callbacks
            }
        }
    }
    
    @discardableResult public func subscribeRequest(ship: String, app: String, path: String, callbacks: SubscribeCallbacks) -> DataRequest {
        let request = SubscribeRequest(id: nextRequestID, ship: ship, app: app, path: path)
        return channelRequest(request).response { [weak self] response in
            if case .success = response.result {
                self?.outstandingSubscribes[request.id] = callbacks
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
