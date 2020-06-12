//
//  EventSource+Extensions.swift
//  Ursus
//
//  Created by Daniel Clelland on 12/06/20.
//

import Foundation
import IKEventSource

public enum Event {
    
    case open
    case message(id: String, data: Data)
    case complete(completion: EventCompletion)
    
}

public enum EventCompletion {
    
    case server(statusCode: Int)
    case client(error: Error)
    
}

extension EventSource {
    
    public func onEvent(_ onEventCallback: @escaping ((Event) -> Void)) {
        onOpen {
            onEventCallback(.open)
        }
        onMessage { id, event, data in
            switch (id, data?.data(using: .utf8)) {
            case (.some(let id), .some(let data)):
                onEventCallback(.message(id: id, data: data))
            default:
                break
            }
        }
        onComplete { statusCode, reconnect, error in
            switch (statusCode, error) {
            case (.some(let statusCode), .none):
                onEventCallback(.complete(completion: .server(statusCode: statusCode)))
            case (.none, .some(let error)):
                onEventCallback(.complete(completion: .client(error: error)))
            default:
                break
            }
        }
    }
    
}
