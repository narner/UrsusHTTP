//
//  Airlock.swift
//  Ursus
//
//  Created by Daniel Clelland on 3/06/20.
//

import Foundation
import Alamofire
import AlamofireEventSource

public class Airlock {
    
    private var pokeHandlers = [Int: (PokeEvent) -> Void]()
    private var subscribeHandlers = [Int: (SubscribeEvent<Data>) -> Void]()
    
    private var eventSourceUID: String = Airlock.uid()
    private var eventSourceCancellationToken: DataStreamRequest.CancellationToken? = nil
    
    private var eventID: Int = 0
    private var requestID: Int = 0
    private var nextRequestID: Int {
        requestID += 1
        return requestID
    }
    
    public var credentials: AirlockCredentials
    
    public var session: Session = .default
    public var encoder: JSONEncoder = AirlockJSONEncoder()
    public var decoder: JSONDecoder = AirlockJSONDecoder()
    
    public init(credentials: AirlockCredentials) {
        self.credentials = credentials
    }
    
    public convenience init(url: URL, code: Code) {
        self.init(credentials: AirlockCredentials(url: url, code: code))
    }
    
    deinit {
        deleteRequest()
    }
    
}

extension Airlock {
    
    #warning("TODO: Use an enum for state management here")
    
    @discardableResult public func connect() -> DataStreamRequest {
        return session.eventSourceRequest(channelURL(uid: eventSourceUID), method: .put, lastEventID: String(eventID))
            .validate()
            .responseEventSource { [weak self] eventSource in
                switch eventSource.event {
                case .message(let message):
                    self?.eventSourceCancellationToken = eventSource.token
                    self?.eventSource(didReceiveMessage: message)
                case .complete(let completion):
                    self?.eventSourceCancellationToken = nil
                    self?.eventSource(didReceiveCompletion: completion)
                }
            }
    }
    
    public func disconnect() {
        eventSourceCancellationToken?.cancel()
    }
    
}

extension Airlock {
    
    @discardableResult public func loginRequest(handler: @escaping (AFResult<Ship>) -> Void) -> DataRequest {
        let parameters = ["password": Code.Prefixless(credentials.code)]
        return session
            .request(loginURL, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default)
            .validate()
            .response(responseSerializer: AirlockLoginResponseSerializer()) { response in
                handler(response.result)
            }
    }
    
    @discardableResult public func logoutRequest() -> DataRequest {
        return session
            .request(logoutURL, method: .post)
            .validate()
    }
    
    @discardableResult public func channelRequest<Parameters: Encodable>(_ parameters: Parameters) -> DataRequest {
        let parameters = [parameters]
        return session
            .request(channelURL(uid: eventSourceUID), method: .put, parameters: parameters, encoder: JSONParameterEncoder(encoder: encoder))
            .validate()
    }
    
    @discardableResult public func scryRequest(app: App, path: Path) -> DataRequest {
        return session
            .request(scryURL(app: app, path: path))
            .validate()
    }
    
}

extension Airlock {
    
    @discardableResult public func ackRequest(eventID: Int) -> DataRequest {
        let request = AckRequest(eventID: eventID)
        return channelRequest(request)
    }
    
    @discardableResult public func pokeRequest<JSON: Encodable>(ship: Ship, app: App, mark: Mark = "json", json: JSON, handler: @escaping (PokeEvent) -> Void) -> DataRequest {
        let id = nextRequestID
        let ship = Ship.Prefixless(ship)
        let request = PokeRequest(id: id, ship: ship, app: app, mark: mark, json: json)
        pokeHandlers[id] = handler
        return channelRequest(request).response { [weak self] response in
            if case .failure = response.result {
                self?.pokeHandlers[id] = nil
            }
        }
    }
    
    @discardableResult public func subscribeRequest(ship: Ship, app: App, path: Path, handler: @escaping (SubscribeEvent<Data>) -> Void) -> DataRequest {
        let id = nextRequestID
        let ship = Ship.Prefixless(ship)
        let request = SubscribeRequest(id: id, ship: ship, app: app, path: path)
        subscribeHandlers[id] = handler
        return channelRequest(request).response { [weak self] response in
            if case .failure = response.result {
                self?.subscribeHandlers[id] = nil
            }
        }
    }
    
    @discardableResult public func subscribeRequest<JSON: Decodable>(ship: Ship, app: App, path: Path, handler: @escaping (SubscribeEvent<JSON>) -> Void) -> DataRequest {
        let decoder = self.decoder
        return subscribeRequest(ship: ship, app: app, path: path) { event in
            handler(event.tryMap { data in
                return try decoder.decode(JSON.self, from: data)
            })
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

extension Airlock {
    
    private func eventSource(didReceiveMessage message: EventSourceMessage) {
        if let id = message.id.flatMap(Int.init) {
            eventID = id
            ackRequest(eventID: id)
        }
        
        if let data = message.data?.data(using: .utf8) {
            switch Result(catching: { try decoder.decode(Response.self, from: data) }) {
            case .success(.poke(let response)):
                switch response.result {
                case .okay:
                    pokeHandlers[response.id]?(.finished)
                    pokeHandlers[response.id] = nil
                case .error(let message):
                    pokeHandlers[response.id]?(.failure(AirlockError.pokeFailure(message)))
                    pokeHandlers[response.id] = nil
                }
            case .success(.subscribe(let response)):
                switch response.result {
                case .okay:
                    subscribeHandlers[response.id]?(.started)
                case .error(let message):
                    subscribeHandlers[response.id]?(.failure(AirlockError.subscribeFailure(message)))
                    subscribeHandlers[response.id] = nil
                }
            case .success(.diff(let response)):
                subscribeHandlers[response.id]?(.update(response.json))
            case .success(.quit(let response)):
                subscribeHandlers[response.id]?(.finished)
                subscribeHandlers[response.id] = nil
            case .failure(let error):
                print("[Ursus] Error decoding message:", message, error)
            }
        }
    }
    
    #warning("TODO: Tidy this method up and test everything")
    #warning("TODO: Decide what to do about the delete request, handlers, and event/request IDs")
    
    private func eventSource(didReceiveCompletion completion: DataStreamRequest.Completion) {
        deleteRequest()
        
        pokeHandlers.values.forEach { handler in
            handler(completion.error.flatMap { .failure($0) } ?? .finished)
        }
        pokeHandlers.removeAll()
        
        subscribeHandlers.values.forEach { handler in
            handler(completion.error.flatMap { .failure($0) } ?? .finished)
        }
        subscribeHandlers.removeAll()
        
//        eventSource = nil
        eventSourceUID = Airlock.uid()

        eventID = 0
        requestID = 0
    }
    
}

extension Airlock {
    
    private var loginURL: URL {
        return credentials.url.appendingPathComponent("/~/login")
    }
    
    private var logoutURL: URL {
        return credentials.url.appendingPathComponent("/~/logout")
    }
    
    private func channelURL(uid: String) -> URL {
        return credentials.url.appendingPathComponent("/~/channel/\(uid)")
    }
    
    private func scryURL(app: App, path: Path) -> URL {
        return credentials.url.appendingPathComponent("/~/scry/\(app)\(path).json")
    }
    
}

extension Airlock {
    
    private static func uid() -> String {
        return "\(Int(Date().timeIntervalSince1970 * 1000))-\(String(Int.random(in: 0...0xFFFFFF), radix: 16))"
    }
    
}
