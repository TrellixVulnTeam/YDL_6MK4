//
//  LanguageCell.swift
//  YDL
//
//  Created by ceonfai on 2019/2/14.
//  Copyright © 2019 Leawo. All rights reserved.
//

import UIKit

class LanguageCell: UITableViewCell {

    var titleLabel: UILabel?
    var iconImageView: UIImageView?
    var cellLine: UIView?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.loadView()
    }
    
    //  Converted to Swift 4 by Swiftify v4.2.34952 - https://objectivec2swift.com/
    func loadView() {
        
        titleLabel = UILabel()
        cellLine = UIView()
        iconImageView = UIImageView()
        
        addSubview(titleLabel!)
        addSubview(iconImageView!)
        
        cellLine?.backgroundColor = RGBA(R: 230, G: 230, B: 230, A: 0.8)
        addSubview(cellLine!)
        
        titleLabel?.snp.makeConstraints({ (make) in
          make.left.equalTo(self.snp.left).offset(IsIPad ? 30:15)
          make.right.equalTo(self.snp.right).offset(60)
          make.height.equalTo(30)
          make.centerY.equalTo(self.snp.centerY)
        })
        
        iconImageView?.snp.makeConstraints({ (make) in
            make.left.equalTo((self.titleLabel?.snp.right)!).offset(20)
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.centerY.equalTo(self.snp.centerY)
        })
        
        cellLine?.snp.makeConstraints({ (make) in
            make.right.equalTo(self.snp.right)
            make.left.equalTo((self.titleLabel?.snp.left)!)
            make.height.equalTo(0.5)
            make.bottom.equalTo(self.snp.bottom)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func height(withData data: Any?) -> CGFloat {
        return 65
    }

    func reset(withData data: Any?) {
        let model = data as? LanguageModel
        if (model != nil) {
            titleLabel?.text = Localized(enKey: (model?.key)!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
