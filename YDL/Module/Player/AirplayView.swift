//
//  AirplayView.swift
//  YDL
//
//  Created by ceonfai on 2019/1/28.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit

class AirplayView: UIView {

    weak var imageView: UIImageView?
    weak var mpAirplayView: MPVolumeView?
    weak var image: UIImage?
    weak var button: UIButton?
   override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        let imgView = UIImageView()
        imageView = imgView
        addSubview(imgView)
        
        let mpAirplayView = MPVolumeView()
    
        self.imageView?.image = FontIcon(withIcon: "\u{e6fc}", size: 40, color: .white)
        
        mpAirplayView.setRouteButtonImage(nil, for: .normal)
        mpAirplayView.showsVolumeSlider = false
        self.mpAirplayView = mpAirplayView
        addSubview(mpAirplayView)
        
    for button in mpAirplayView.subviews {
        
        if (button is UIButton) {
            self.button = (button as! UIButton)
            button.addObserver(self, forKeyPath: "alpha", options: .new, context: nil)
        }
       }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (object is UIButton) {
            let button = object as! UIButton
           
            if (change?[.newKey] as? NSNumber)?.intValue ?? 0 == 1 {
                button.bounds = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
            } else {
                mpAirplayView!.isHidden = false
                button.alpha = 1.0
            }
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let scaleW: CGFloat = frame.size.width / 30
        let scaleH: CGFloat = frame.size.height / 34
        let scale: CGFloat = scaleH > scaleW ? scaleH : scaleW
        mpAirplayView!.transform = CGAffineTransform(a: scale, b: 0, c: 0, d: scale, tx: frame.size.width / 2, ty: frame.size.height / 2)
        imageView?.frame = CGRect(x: 12.5 / 2, y: 2, width: 25, height: 25)
    }

    deinit {
        /// 移除通知
        self.button!.removeObserver(self, forKeyPath: "alpha")
    }
}
    
