//
//  Event.swift
//  EventSource
//
//  Created by Andres on 01/06/2019.
//  Copyright © 2019 inaka. All rights reserved.
//

import Foundation

struct Event {
    
    var id: String?
    var event: String?
    var data: String?
    
    init(id: String?, event: String?, data: String?) {
        self.id = id
        self.event = event
        self.data = data
    }

    init?(eventString: String?, newlineCharacters: [String]) {
        guard let eventString = eventString else { return nil }

        if eventString.hasPrefix(":") {
            return nil
        }

        self = Event.parseEvent(eventString, newlineCharacters: newlineCharacters)
    }

}

private extension Event {

    static func parseEvent(_ eventString: String, newlineCharacters: [String]) -> Event {
        var event: [String: String?] = [:]

        for line in eventString.components(separatedBy: CharacterSet.newlines) as [String] {
            let (akey, value) = Event.parseLine(line, newlineCharacters: newlineCharacters)
            guard let key = akey else { continue }

            if let value = value, let previousValue = event[key] ?? nil {
                event[key] = "\(previousValue)\n\(value)"
            } else if let value = value {
                event[key] = value
            } else {
                event[key] = nil
            }
        }

        // the only possible field names for events are: id, event and data. Everything else is ignored.
        return Event(
            id: event["id"] ?? nil,
            event: event["event"] ?? nil,
            data: event["data"] ?? nil
        )
    }

    static func parseLine(_ line: String, newlineCharacters: [String]) -> (key: String?, value: String?) {
        var key: NSString?, value: NSString?
        let scanner = Scanner(string: line)
        scanner.scanUpTo(":", into: &key)
        scanner.scanString(":", into: nil)

        for newline in newlineCharacters {
            if scanner.scanUpTo(newline, into: &value) {
                break
            }
        }

        // for id and data if they come empty they should return an empty string value.
        if key != "event" && value == nil {
            value = ""
        }

        return (key as String?, value as String?)
    }
}
