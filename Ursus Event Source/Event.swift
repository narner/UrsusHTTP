//
//  Event.swift
//  EventSource
//
//  Created by Andres on 01/06/2019.
//  Copyright © 2019 inaka. All rights reserved.
//

import Foundation

public struct Event {
    
    #warning("Should have the fields event (String), id (String), data (Data), retry (Integer milliseconds)")
    
    public var id: String?
    public var data: Data

}

extension Event {

    internal static func parseEvent(_ string: String) -> Event {
        var event: [String: String?] = [:]

        for line in string.components(separatedBy: CharacterSet.newlines) as [String] {
            let (akey, value) = Event.parseLine(line)
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
            data: event["data"]??.data(using: .utf8) ?? Data()
        )
    }

    internal static func parseLine(_ line: String) -> (key: String?, value: String?) {
        var key: String?, value: String?
        let scanner = Scanner(string: line)
        key = scanner.scanUpToString(":")
        _ = scanner.scanString(":")
        value = scanner.scanUpToString("\n")

        // for id and data if they come empty they should return an empty string value.
        if key != "event" && value == nil {
            value = ""
        }

        return (key, value)
    }
    
}
