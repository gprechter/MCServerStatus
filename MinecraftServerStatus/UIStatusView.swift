//
//  UIStatusView.swift
//  MinecraftServerStatus
//
//  Created by Griffin Prechter on 8/14/18.
//  Copyright © 2018 Griffin Prechter. All rights reserved.
//

import UIKit

class UIStatusView: UIView{
    
    var status: Status = Status.connecting /*{
        didSet {self.setNeedsDisplay()}
    }*/
    
    enum Status {
        case connected
        case disconnected
        case connecting
        
        var color: UIColor {
            switch self {
                case .connected: return .green
                case .disconnected: return .red
                case .connecting: return .yellow
            }
        }
        
    }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: (bounds.width - 10) / 2, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        path.lineWidth = 1.0
        UIColor.gray.setStroke()
        self.status.color.setFill()
        path.fill()
        path.stroke()
    }
}
