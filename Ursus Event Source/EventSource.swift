//
//  EventSource.swift
//  EventSource
//
//  Created by Andres on 2/13/15.
//  Copyright (c) 2015 Inaka. All rights reserved.
//

import Foundation

public protocol EventSourceDelegate: class {
    
    func eventSource(_ eventSource: EventSource, didReceiveEvent event: Event)
    
    func eventSource(_ eventSource: EventSource, didCompleteWithError error: Error?)
    
}

public class EventSource: NSObject {
    
    private var session: URLSession?
    private var parser = EventSourceParser()

    public let url: URL
    public weak var delegate: EventSourceDelegate?

    public init(url: URL, delegate: EventSourceDelegate? = nil) {
        self.url = url
        self.delegate = delegate
        super.init()
    }

    public func connect(lastEventID: String? = nil) {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        
        session = URLSession(configuration: .eventSource(lastEventID: lastEventID), delegate: self, delegateQueue: operationQueue)
        session?.dataTask(with: url).resume()
    }

    public func disconnect() {
        session?.invalidateAndCancel()
    }
    
}

extension EventSource: URLSessionDataDelegate {
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        for event in parser.append(data: data) {
            DispatchQueue.main.async { [weak self] in
                if let `self` = self {
                    self.delegate?.eventSource(self, didReceiveEvent: event)
                }
            }
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async { [weak self] in
            if let `self` = self {
                self.delegate?.eventSource(self, didCompleteWithError: error)
            }
        }
    }
    
}
