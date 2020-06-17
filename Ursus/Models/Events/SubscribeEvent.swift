//
//  SubscribeEvent.swift
//  Ursus
//
//  Created by Daniel Clelland on 10/06/20.
//

import Foundation

public enum SubscribeEvent<Input, Failure: Error> {

    case started
    case update(Input)
    case finished
    case failure(Failure)

}

extension SubscribeEvent {
    
    internal func map<T>(_ transform: (Input) throws -> T) -> SubscribeEvent<T, Error> {
        switch self {
        case .started:
            return .started
        case .update(let input):
            do {
                return .update(try transform(input))
            } catch let error {
                return .failure(error)
            }
        case .finished:
            return .finished
        case .failure(let error):
            return .failure(error)
        }
    }
    
}
