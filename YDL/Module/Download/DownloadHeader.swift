//
//  DowncreateTitle.swift
//  YDL
//
//  Created by ceonfai on 2019/1/28.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit

class DownloadHeader: UIView {

    var titleLabel:UILabel?
    
   override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = RGBA(R: 245, G: 245, B: 245, A: 1.0)
        createTitle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createTitle() {
        
        self.titleLabel = UILabel(frame: CGRect(x: 15, y: 0, width: frame.size.width - 15, height: frame.size.height))
        self.titleLabel!.font = UIFont.systemFont(ofSize: 13.0)
        self.titleLabel!.textColor = UIColor.darkGray
        addSubview(self.titleLabel!)
    }
    
    func updateTitle(_ text: String?) {
        
        self.titleLabel!.text = text
    }


}
