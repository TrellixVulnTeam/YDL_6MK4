//
//  FontReader.swift
//  YDL
//
//  Created by ceonfai on 2018/12/22.
//  Copyright © 2018 Ceonfai. All rights reserved.
//

import Foundation
import UIKit
func FontIcon(withIcon iconCode: String?, size: Int, color: UIColor?) -> UIImage? {
    
    let font = UIFont(name: "iconfont", size: CGFloat(size))
    UIGraphicsBeginImageContext(CGSize(width: CGFloat(size), height: CGFloat(size)))
    
    if let font = font, let color = color {
        iconCode?.draw(at: CGPoint.zero, withAttributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color])
    }
    
    var image: UIImage? = nil
    if let CGImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage {
        image = UIImage(cgImage: CGImage, scale: 2.0, orientation: .up)
    }
    UIGraphicsEndImageContext()
    
    return image!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
}
