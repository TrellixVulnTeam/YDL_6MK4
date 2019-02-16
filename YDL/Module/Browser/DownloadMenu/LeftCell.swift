//
//  LeftCell.swift
//  YDL
//
//  Created by ceonfai on 2019/1/10.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit

class LeftCell: UITableViewCell {

    lazy var nameLabel = UILabel()
    private lazy var yellowView = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        self.textLabel?.font = UIFont(name: "TimesNewRomanPS-BoldMT", size: CGFloat(12))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitleText(text:String) -> Void {
        self.textLabel?.text = text
    }
    
    func refreshState(onClicked:Bool) -> Void {
        contentView.backgroundColor = onClicked ?UIColor(white: 0, alpha: 0.1):.white
        self.textLabel?.textColor = onClicked ?.black:.darkGray
    }

}
