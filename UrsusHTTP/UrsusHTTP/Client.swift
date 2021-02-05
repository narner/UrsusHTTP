//
//  Client.swift
//  Ursus
//
//  Created by Daniel Clelland on 3/06/20.
//

import Foundation
import Alamofire
import AlamofireEventSource

public class Client {
    
    private var eventSource: DataStreamRequest? = nil
    private var eventSourceUID: String = Client.uid()
    
    private var eventID: Int = 0
    private var requestID: Int = 0
    private var nextRequestID: Int {
        requestID += 1
        return requestID
    }
    
    private var pokeHandlers = [Int: (PokeEvent) -> Void]()
    private var subscribeHandlers = [Int: (SubscribeEvent<Data>) -> Void]()
    
    public let session: Session
    public let credentials: Credentials
    
    public init(session: Session = .default, credentials: Credentials) {
        self.session = session
        self.credentials = credentials
    }
    
    public convenience init(session: Session = .default, url: URL, code: Code) {
        self.init(session: session, credentials: Credentials(url: url, code: code))
    }
    
    deinit {
        deleteRequest()
    }
    
}

extension Client {
    
    @discardableResult public func connect() -> DataStreamRequest {
        eventSource = eventSource ?? session.eventSourceRequest(channelURL(uid: eventSourceUID), method: .put, lastEventID: String(eventID))
            .validate()
            .responseDecodableEventSource(using: DecodableEventSourceSerializer<Response>(decoder: ClientJSONDecoder())) { [weak self] eventSource in
                switch eventSource.event {
                case .message(let message):
                    self?.eventSource(didReceiveMessage: message)
                case .complete(let completion):
                    self?.eventSource(didReceiveCompletion: completion)
                }
            }
        
        return eventSource!
    }
    
    public func disconnect() {
        eventSource?.cancel()
    }
    
}

extension Client {
    
    @discardableResult public func loginRequest(handler: @escaping (AFResult<Ship>) -> Void) -> DataRequest {
        let parameters = ["password": Code.Prefixless(credentials.code)]
        return session
            .request(loginURL, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default)
            .validate()
            .response(responseSerializer: ClientLoginResponseSerializer()) { response in
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
            .request(channelURL(uid: eventSourceUID), method: .put, parameters: parameters, encoder: JSONParameterEncoder(encoder: ClientJSONEncoder()))
            .validate()
    }
    
    @discardableResult public func scryRequest(app: App, path: Path) -> DataRequest {
        return session
            .request(scryURL(app: app, path: path))
            .validate()
    }
    
    @discardableResult public func spiderRequest(input: Mark, thread: Thread, output: Mark) -> DataRequest {
        return session
            .request(spiderURL(input: input, thread: thread, output: output))
            .validate()
    }
    
}

extension Client {
    
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
    
    @discardableResult public func subscribeRequest<JSON: Decodable>(ship: Ship, app: App, path: Path, handler: @escaping (SubscribeEvent<Result<JSON, Error>>) -> Void) -> DataRequest {
        let decoder = ClientJSONDecoder()
        return subscribeRequest(ship: ship, app: app, path: path) { event in
            handler(event.map { data in
                return Result(catching: { try decoder.decode(JSON.self, from: data) })
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

extension Client {
    
    private func eventSource(didReceiveMessage message: DecodableEventSourceMessage<Response>) {
        if let id = message.id.flatMap(Int.init) {
            eventID = id
            ackRequest(eventID: id)
        }
        
        if let data = message.data {
            switch data {
            case .poke(let response):
                switch response.result {
                case .okay:
                    pokeHandlers[response.id]?(.finished)
                    pokeHandlers[response.id] = nil
                case .error(let message):
                    pokeHandlers[response.id]?(.failure(.pokeFailure(message)))
                    pokeHandlers[response.id] = nil
                }
            case .subscribe(let response):
                switch response.result {
                case .okay:
                    subscribeHandlers[response.id]?(.started)
                case .error(let message):
                    subscribeHandlers[response.id]?(.failure(.subscribeFailure(message)))
                    subscribeHandlers[response.id] = nil
                }
            case .diff(let response):
                print("DIFF: \(String(data: response.json, encoding: .utf8)!)")
                subscribeHandlers[response.id]?(.update(response.json))
            case .quit(let response):
                subscribeHandlers[response.id]?(.finished)
                subscribeHandlers[response.id] = nil
            }
        }
    }
    
    private func eventSource(didReceiveCompletion completion: DataStreamRequest.Completion) {
        deleteRequest()
        
        eventSource = nil
        eventSourceUID = Client.uid()

        eventID = 0
        requestID = 0
        
        pokeHandlers.removeAll()
        subscribeHandlers.removeAll()
    }
    
}

extension Client {
    
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
    
    private func spiderURL(input: Mark, thread: Thread, output: Mark) -> URL {
        return credentials.url.appendingPathComponent("/spider/\(input)/\(thread)/\(output).json")
    }
    
}

extension Client {
    
    private static func uid() -> String {
        return "\(Int(Date().timeIntervalSince1970 * 1000))-\(String(Int.random(in: 0...0xFFFFFF), radix: 16))"
    }
    
}
