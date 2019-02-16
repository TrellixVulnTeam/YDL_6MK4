//
//  BaseItem.swift
//  YDL
//
//  Created by ceonfai on 2019/2/13.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit

enum BaseItemType : Int {
    case none
    case arrow
    case switched
}

class BaseItem: NSObject {

    var icon = ""
    /// 标题
    var title = ""
    /// 设置开关
    var switchOn = false
    /// cell的样式
    var type: BaseItemType?
    /// cell上开关的操作事件
    var switchBlock: ((_ on: Bool) -> Void)?
    /// 点击cell后要执行的操作
    var operation: (() -> Void)?
    
    func setupItem(iconStr:String,titleStr:String,itemType:BaseItemType) -> Void {
        
        icon = iconStr
        title = titleStr
        type = itemType
    }
}
