//
//  Ursus.swift
//  Ursus
//
//  Created by Daniel Clelland on 3/06/20.
//

import Foundation
import Alamofire
import IKEventSource

public class Ursus {
    
    private var session: Session = .default
    private var eventSource: EventSource? = nil
    
    private var pokeHandlers: [Int: (PokeEvent) -> Void] = [:]
    private var subscribeHandlers: [Int: (SubscribeEvent) -> Void] = [:]
    
    private var uid: String = Ursus.uid
    
    private var requestID: Int = 0
    private var nextRequestID: Int {
        requestID += 1
        return requestID
    }
    
    private var lastEventID: String? = nil
    
    public var url: URL
    public var code: String
    
    public init(url: URL, code: String) {
        self.url = url
        self.code = code
    }
    
    public func reset() {
        deleteRequest()
        
        eventSource = nil
        
        pokeHandlers.removeAll()
        subscribeHandlers.removeAll()
        
        uid = Ursus.uid
        
        requestID = 0
        lastEventID = nil
    }
    
    deinit {
        deleteRequest()
    }
    
}

extension Ursus {
    
    private static var uid: String {
        return "\(Int(Date().timeIntervalSince1970 * 1000))-\(String(format: "%06x", Int.random(in: 0x000000...0xFFFFFF)))"
    }
    
}

extension Ursus {
    
    private var authenticationURL: URL {
        return url.appendingPathComponent("/~/login")
    }
    
    private var channelURL: URL {
        return url.appendingPathComponent("/~/channel/\(uid)")
    }
    
}

extension Ursus {
    
    @discardableResult public func authenticationRequest() -> DataRequest {
        return session.request(authenticationURL, method: .post, parameters: ["password": code], encoder: URLEncodedFormParameterEncoder.default)
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
        
        print("Disconnected, connecting")
        
        eventSource = EventSource(url: channelURL)
        eventSource?.onOpen {
            print("onOpen")
        }
        eventSource?.onMessage { [weak self] id, event, data in
            self?.lastEventID = id ?? self?.lastEventID
            
            do {
                guard let data = data?.data(using: .utf8) else {
                    return
                }
                
                let response = try JSONDecoder().decode(Response.self, from: data)
                switch response {
                case .poke(let response):
                    switch response.result {
                    case .success:
                        self?.pokeHandlers[response.id]?(.success)
                        self?.pokeHandlers[response.id] = nil
                    case .failure(let error):
                        self?.pokeHandlers[response.id]?(.failure(error))
                        self?.pokeHandlers[response.id] = nil
                    }
                case .subscribe(let response):
                    switch response.result {
                    case .success:
                        self?.subscribeHandlers[response.id]?(.success)
                    case .failure(let error):
                        self?.subscribeHandlers[response.id]?(.failure(error))
                        self?.subscribeHandlers[response.id] = nil
                    }
                case .diff(let response):
                    self?.subscribeHandlers[response.id]?(.message(response.json))
                case .quit(let response):
                    self?.subscribeHandlers[response.id]?(.quit)
                    self?.subscribeHandlers[response.id] = nil
                }
            } catch let error {
                print("Error decoding message:", error)
            }
        }
        eventSource?.onComplete { [weak self] status, reconnect, error in
            #warning("Should this forward the error to all the poke/subscribe handlers before removal?")
            self?.reset()
            
            print("Error from event source:", status, reconnect, error)
        }
        eventSource?.connect(lastEventId: lastEventID)
    }
    
}

extension Ursus {
    
    @discardableResult public func ackRequest(eventID: Int) -> DataRequest {
        let request = AckRequest(eventID: eventID)
        return channelRequest(request)
    }
    
    @discardableResult public func pokeRequest<JSON: Encodable>(ship: String, app: String, mark: String, json: JSON, handler: @escaping (PokeEvent) -> Void) -> DataRequest {
        let id = nextRequestID
        let request = PokeRequest(id: id, ship: ship, app: app, mark: mark, json: json)
        return channelRequest(request).response { [weak self] response in
            if case .success = response.result {
                self?.pokeHandlers[id] = handler
            }
        }
    }
    
    @discardableResult public func subscribeRequest(ship: String, app: String, path: String, handler: @escaping (SubscribeEvent) -> Void) -> DataRequest {
        let id = nextRequestID
        let request = SubscribeRequest(id: id, ship: ship, app: app, path: path)
        return channelRequest(request).response { [weak self] response in
            if case .success = response.result {
                self?.subscribeHandlers[id] = handler
            }
        }
    }
    
    @discardableResult public func unsubscribeRequest(subscriptionID: Int) -> DataRequest {
        let id = nextRequestID
        let request = UnsubscribeRequest(id: id, subscriptionID: subscriptionID)
        return channelRequest(request)
    }
    
    @discardableResult public func deleteRequest() -> DataRequest {
        let request = DeleteRequest()
        return channelRequest(request)
    }
    
}
