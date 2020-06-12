//
//  EventSource+Extensions.swift
//  Ursus
//
//  Created by Daniel Clelland on 12/06/20.
//

import Foundation
import IKEventSource

enum Event {
    
    case open
    case message(id: String, data: Data)
    case complete(error: EventError)
    
}

enum EventError: Error {
    
    case client(error: Error)
    case server(statusCode: Int)
    
}

extension EventSource {
    
    func onEvent(_ onEventCallback: @escaping ((Event) -> Void)) {
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
            case (.none, .some(let error)):
                onEventCallback(.complete(error: .client(error: error)))
            case (.some(let statusCode), .none):
                onEventCallback(.complete(error: .server(statusCode: statusCode)))
            default:
                break
            }
        }
    }
    
}
