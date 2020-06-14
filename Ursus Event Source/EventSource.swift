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

public enum EventSourceState {
    
    case connecting
    case open
    case closed
    
}

open class EventSource: NSObject {
    static let DefaultRetryTime = 3000

    public let url: URL
    public weak var delegate: EventSourceDelegate?
    private(set) public var retryTime = EventSource.DefaultRetryTime
    private(set) public var headers: [String: String]
    private(set) public var readyState: EventSourceState

    private var eventStreamParser: EventStreamParser?
    private var operationQueue: OperationQueue
    private var urlSession: URLSession?

    public init(url: URL, headers: [String: String] = [:]) {
        self.url = url
        self.headers = headers

        readyState = .closed
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1

        super.init()
    }

    public func connect(lastEventID: String? = nil) {
        eventStreamParser = EventStreamParser()
        readyState = .connecting

        let configuration = sessionConfiguration(lastEventID: lastEventID)
        urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
        urlSession?.dataTask(with: url).resume()
    }

    public func disconnect() {
        readyState = .closed
        urlSession?.invalidateAndCancel()
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
        if readyState != .open {
            return
        }

        if let events = eventStreamParser?.append(data: data) {
            notifyReceivedEvents(events)
        }
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(.allow)
        readyState = .open
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

    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        var newRequest = request
        headers.forEach { newRequest.setValue($1, forHTTPHeaderField: $0) }
        completionHandler(newRequest)
    }
    
}

internal extension EventSource {

    func sessionConfiguration(lastEventID: String?) -> URLSessionConfiguration {
        var additionalHeaders = headers
        
        if let lastEventID = lastEventID {
            additionalHeaders["Last-Event-Id"] = lastEventID
        }

        additionalHeaders["Accept"] = "text/event-stream"
        additionalHeaders["Cache-Control"] = "no-cache"

        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = TimeInterval(INT_MAX)
        sessionConfiguration.timeoutIntervalForResource = TimeInterval(INT_MAX)
        sessionConfiguration.httpAdditionalHeaders = additionalHeaders

        return sessionConfiguration
    }

    func readyStateOpen() {
        readyState = .open
    }
    
}

private extension EventSource {

    func notifyReceivedEvents(_ events: [Event]) {
        for event in events {
            retryTime = event.retryTime ?? EventSource.DefaultRetryTime

            if event.onlyRetryEvent == true {
                continue
            }
            
            switch (event.id, event.data?.data(using: .utf8)) {
            case (.some(let id), .some(let data)):
                didReceiveEvent(.message(id: id, data: data))
            default:
                break
            }
        }
    }

}
