//
//  BaseCell.swift
//  YDL
//
//  Created by ceonfai on 2019/2/13.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit

class BaseCell: UITableViewCell {

    var switchView = UISwitch()
    var item = BaseItem()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
       super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func setItem(_ item: BaseItem?) {
        self.item = item!
        // 设置数据
        imageView?.image = item?.icon.count != nil ? UIImage(named: item?.icon ?? "") : nil
        textLabel?.text = item?.title
        if item?.type == BaseItemType.arrow {
            self.accessoryType = .disclosureIndicator
            // 用默认的选中样式
            self.selectionStyle = .blue
        } else if item?.type == BaseItemType.switched {
            if switchView.isEqual(nil) == true {
                switchView = UISwitch()
                switchView.isOn = (item?.switchOn)!
                switchView.addTarget(self, action: #selector(switchStatusChanged), for: .valueChanged)
            } else {
                switchView.setOn(item?.switchOn != nil, animated: true)
            }
            // 右边显示开关
            self.accessoryView = switchView
            
            // 禁止选中
            self.selectionStyle = .none
        } else {
            // 什么也没有，清空右边显示的view
            self.accessoryView = nil
            // 用默认的选中样式
            self.selectionStyle = .blue
        }
    }
    
    @objc func switchStatusChanged(_ sender: UISwitch?) {
        if (item.switchBlock != nil) {
            item.switchBlock!((sender?.isOn)!)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
