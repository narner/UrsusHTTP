//
//  EventSource.swift
//  EventSource
//
//  Created by Andres on 2/13/15.
//  Copyright (c) 2015 Inaka. All rights reserved.
//

import Foundation

public protocol EventSourceDelegate: class {
    
    func eventSource(_ eventSource: EventSource, didReceiveEvent event: EventSourceEvent)
    
}

public enum EventSourceEvent {
    
    case open
    case message(id: String, data: Data)
    case complete(result: Result<HTTPURLResponse, Error>)
    
}

public enum EventSourceState {
    
    case connecting
    case open
    case closed
    
}

open class EventSource: NSObject {

    public let url: URL
    public weak var delegate: EventSourceDelegate?
    private(set) public var state: EventSourceState

    private var operationQueue: OperationQueue
    private var session: URLSession?
    
    private var parser = EventSourceParser()

    public init(url: URL) {
        self.url = url

        self.state = .closed
        self.operationQueue = OperationQueue()
        self.operationQueue.maxConcurrentOperationCount = 1

        super.init()
    }

    public func connect(lastEventID: String? = nil) {
        state = .connecting

        session = URLSession(configuration: .eventSource(lastEventID: lastEventID), delegate: self, delegateQueue: operationQueue)
        session?.dataTask(with: url).resume()
    }

    public func disconnect() {
        state = .closed
        session?.invalidateAndCancel()
    }
    
}

extension EventSource {
    
    func didReceiveEvent(_ event: EventSourceEvent) {
        DispatchQueue.main.async { [weak self] in
            if let `self` = self {
                self.delegate?.eventSource(self, didReceiveEvent: event)
            }
        }
    }
    
}

extension EventSource: URLSessionDataDelegate {
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if state != .open {
            return
        }
        
        for event in parser.append(data: data) {
            switch (event.id, event.data?.data(using: .utf8)) {
            case (.some(let id), .some(let data)):
                didReceiveEvent(.message(id: id, data: data))
            default:
                break
            }
        }
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(.allow)
        state = .open
        didReceiveEvent(.open)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        switch (task.response as? HTTPURLResponse, error) {
        case (.some(let response), .none):
            didReceiveEvent(.complete(result: .success(response)))
        case (.none, .some(let error)):
            didReceiveEvent(.complete(result: .failure(error)))
        default:
            break
        }
    }
    
}
