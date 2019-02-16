//
//  SettingHeader.swift
//  YDL
//
//  Created by ceonfai on 2019/2/13.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit

class SettingHeader: UIView {

    var iconView = UIImageView()
    var versionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createHeader()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createHeader() -> Void {
        
        iconView.image = UIImage.init(named: "logo")
        iconView.layer.cornerRadius = 30
        iconView.layer.masksToBounds = true
        iconView.layer.borderColor = UIColor.white.cgColor
        iconView.layer.borderWidth = 0.2
        self.addSubview(iconView)
        
        
        versionLabel = UILabel()
        versionLabel.font = UIFont(name: "HelveticaNeue", size: IsIPad ? 22 : 18)
        versionLabel.textColor = UIColor.gray
        versionLabel.textAlignment = .center
        let versioText = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        let appName = Localized(enKey: "YDL")
        let versionLabText = appName + " " + "V" + versioText!
        versionLabel.text = versionLabText
        self.addSubview(versionLabel)
        
        iconView.snp.makeConstraints { (make) in
            make.top.equalTo(10);
            make.left.equalTo(self.snp.centerX).offset(-30)
            make.width.equalTo(60);
            make.height.equalTo(60);
        }

        versionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.bottom);
            make.left.equalTo(0);
            make.width.equalTo(self.snp.width);
            make.height.equalTo(30);
        }
    }

 
}
