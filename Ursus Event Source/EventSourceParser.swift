//
//  EventSourceParser.swift
//  EventSource
//
//  Created by Andres on 30/05/2019.
//  Copyright © 2019 inaka. All rights reserved.
//

import Foundation

internal class EventSourceParser {
    
    private let delimiter: Data = "\n\n".data(using: .utf8)!
    
    private var buffer = Data()

    internal func append(data: Data) -> [Event] {
        buffer.append(data)
        
        return extractEventsFromBuffer().map { string in
            return Event.parseEvent(string)
        }
    }
    
}

extension EventSourceParser {

    private func extractEventsFromBuffer() -> [String] {
        var events = [String]()
        var searchRange: Range<Data.Index> = buffer.startIndex..<buffer.endIndex
        
        while let foundRange = buffer.range(of: delimiter, in: searchRange) {
            let subdata = buffer.subdata(in: searchRange.startIndex..<foundRange.endIndex)

            if let event = String(bytes: subdata, encoding: .utf8) {
                events.append(event)
            }

            searchRange = foundRange.endIndex..<buffer.endIndex
        }

        buffer.removeSubrange(buffer.startIndex..<searchRange.startIndex)

        return events
    }
    
}
