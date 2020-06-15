//
//  Event.swift
//  EventSource
//
//  Created by Andres on 01/06/2019.
//  Copyright © 2019 inaka. All rights reserved.
//

import Foundation

public struct EventSourceMessage {
    
    public var event: String?
    public var id: String?
    public var data: String?
    public var retry: String?
    
    internal init?(parsing string: String) {
        let fields = string.components(separatedBy: "\n").compactMap { string in
            return EventSourceMessageField(parsing: string)
        }
        
        for field in fields {
            switch field {
            case .event(let string):
                if let event = self.event {
                    self.event = event + "\n" + string
                } else {
                    self.event = string
                }
            case .id(let string):
                if let id = self.id {
                    self.id = id + "\n" + string
                } else {
                    self.id = string
                }
            case .data(let string):
                if let data = self.data {
                    self.data = data + "\n" + string
                } else {
                    self.data = string
                }
            case .retry(let string):
                if let retry = self.retry {
                    self.retry = retry + "\n" + string
                } else {
                    self.retry = string
                }
            }
        }
    }

}
