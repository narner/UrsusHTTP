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
    
    private var encoder: JSONEncoder = .init()
    private var decoder: JSONDecoder = .init()
    
    private var pokeHandlers: [Int: (PokeEvent) -> Void] = [:]
    private var subscribeHandlers: [Int: (SubscribeEvent) -> Void] = [:]
    
    private var uid: String = Ursus.uid()
    
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
        
        uid = Ursus.uid()
        
        requestID = 0
        lastEventID = nil
    }
    
    deinit {
        deleteRequest()
    }
    
}

extension Ursus {
    
    private static func uid() -> String {
        return "\(Int(Date().timeIntervalSince1970 * 1000))-\(String(Int.random(in: 0...0xFFFFFF), radix: 16))"
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
        return session.request(authenticationURL, method: .post, parameters: ["password": code], encoder: URLEncodedFormParameterEncoder.default).validate()
    }
    
    @discardableResult public func channelRequest<Parameters: Encodable>(_ parameters: Parameters) -> DataRequest {
        return session.request(channelURL, method: .put, parameters: [parameters], encoder: JSONParameterEncoder(encoder: encoder)).validate().response { [weak self] _ in
            self?.connectIfDisconnected()
        }
    }
    
}

#warning("TODO: Tidy this up")
extension CodingUserInfoKey {
    
    static let json = CodingUserInfoKey(rawValue: "json")!
    
}

extension Ursus {
    
    private func connectIfDisconnected() {
        guard eventSource == nil else {
            return
        }
        
        eventSource = EventSource(url: channelURL)
        eventSource?.onEvent { [weak self] event in
            guard let `self` = self else {
                return
            }
            
            switch event {
            case .open:
                break
            case .message(let id, let data):
                self.lastEventID = id
                
                do {
                    #warning("TODO: Tidy this up")
                    self.decoder.userInfo[.json] = try JSONSerialization.jsonObject(with: data)
                    let response = try self.decoder.decode(Response.self, from: data)
                    switch response {
                    case .poke(let response):
                        switch response.result {
                        case .success:
                            self.pokeHandlers[response.id]?(.success)
                            self.pokeHandlers[response.id] = nil
                        case .failure(let error):
                            self.pokeHandlers[response.id]?(.failure(error))
                            self.pokeHandlers[response.id] = nil
                        }
                    case .subscribe(let response):
                        switch response.result {
                        case .success:
                            self.subscribeHandlers[response.id]?(.success)
                        case .failure(let error):
                            self.subscribeHandlers[response.id]?(.failure(error))
                            self.subscribeHandlers[response.id] = nil
                        }
                    case .diff(let response):
                        self.subscribeHandlers[response.id]?(.message(response.json))
                    case .quit(let response):
                        self.subscribeHandlers[response.id]?(.quit)
                        self.subscribeHandlers[response.id] = nil
                    }
                } catch let error {
                    print("[Ursus] Error decoding message:", error)
                }
            case .complete(let error):
                self.pokeHandlers.values.forEach { handler in
                    handler(.failure(error))
                }
                self.subscribeHandlers.values.forEach { handler in
                    handler(.failure(error))
                }
                
                self.pokeHandlers.removeAll()
                self.subscribeHandlers.removeAll()
                
                self.reset()
            }
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
        pokeHandlers[id] = handler
        return channelRequest(request).response { [weak self] response in
            if let error = response.error {
                self?.pokeHandlers[id]?(.failure(error))
                self?.pokeHandlers[id] = nil
            }
        }
    }
    
    @discardableResult public func subscribeRequest(ship: String, app: String, path: String, handler: @escaping (SubscribeEvent) -> Void) -> DataRequest {
        let id = nextRequestID
        let request = SubscribeRequest(id: id, ship: ship, app: app, path: path)
        subscribeHandlers[id] = handler
        return channelRequest(request).response { [weak self] response in
            if let error = response.error {
                self?.subscribeHandlers[id]?(.failure(error))
                self?.subscribeHandlers[id] = nil
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
