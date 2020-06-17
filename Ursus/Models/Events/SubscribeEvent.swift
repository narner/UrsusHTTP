//
//  SubscribeEvent.swift
//  Ursus
//
//  Created by Daniel Clelland on 10/06/20.
//

import Foundation

public enum SubscribeEvent<Input> {

    case started
    case update(Input)
    case finished
    case failure(SubscribeError)

}
