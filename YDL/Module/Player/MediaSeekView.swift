//
//  MediaSeekView.swift
//  YDL
//
//  Created by ceonfai on 2019/2/12.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit

class MediaSeekView: UIView {

    let actImageView:UIImageView = UIImageView()
    let seekLabel:UILabel = UILabel()
    let rewinImage:UIImage = FontIcon(withIcon: "\u{e662}", size: 80, color: .white)!
    let fastImage:UIImage = FontIcon(withIcon: "\u{e661}", size: 80, color: .white)!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createSeekTime()
    }
    
    func createSeekTime() -> Void {
        
        self.backgroundColor = RGBA(R: 0, G: 0, B: 0, A: 0.4)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
        
        actImageView.image = fastImage
        self.addSubview(actImageView)
        
        seekLabel.text = "--:--/--:--"
        seekLabel.font = UIFont.systemFont(ofSize: 18.0)
        seekLabel.textColor = .white
        seekLabel.textAlignment = .center
        self.addSubview(seekLabel)
        
        actImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.centerY).offset(-10)
            make.width.height.equalTo(60)
            make.centerX.equalTo(self.snp.centerX)
        }
        seekLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.actImageView.snp.bottom).offset(10)
            make.width.equalTo(self.snp.width)
            make.height.equalTo(20)
            make.centerX.equalTo(self.snp.centerX)
        }
    }
    
    func updateSeekInfo(text:String,isRewin:Bool) -> Void {
        actImageView.image = isRewin ?self.rewinImage:self.fastImage
        seekLabel.text = text
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
