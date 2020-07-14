//
//  SigilView.swift
//  Alamofire
//
//  Created by Daniel Clelland on 14/07/20.
//

import Foundation
import SwiftUI
import SwiftSVG

public struct SigilView: UIViewRepresentable {
    
    public var ship: Ship
    
    public init(ship: Ship) {
        self.ship = ship
    }
    
    public func makeUIView(context: Context) -> UIView {
        return UIView(SVGData: Sigil(ship: ship).symbol.svgData())
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
}
