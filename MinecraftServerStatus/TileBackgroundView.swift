//
//  TileBackgroundView.swift
//  MinecraftServerStatus
//
//  Created by Griffin Prechter on 8/14/18.
//  Copyright © 2018 Griffin Prechter. All rights reserved.
//

import UIKit

class TileBackgroundView: UIView {
    @IBInspectable var image: UIImage?
    @IBInspectable var xPixels: Int = 0
    @IBInspectable var yPixels: Int = 0
    override func draw(_ rect: CGRect) {
        if let image = image?.resize(to: CGSize(width: 8*xPixels, height: 8*yPixels)) {
            image.drawAsPattern(in: rect)
        }
    }
    
    

}

extension UIImage {
    func resize(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
