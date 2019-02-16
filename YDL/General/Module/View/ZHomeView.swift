//
//  ZHomeView.swift
//  zTube
//
//  Created by ceonfai on 2018/12/27.
//  Copyright © 2018 Leawo. All rights reserved.
//

import UIKit

class ZHomeView: UIView {
    
    var previewTable:UITableView?
    var transView:UIView?
    var editDatas:NSMutableArray?
    

    override init(frame: CGRect) {
      super.init(frame: frame)
        setupSubviews()
    }
    
    func setupSubviews() -> Void {
        
        //初始化TableView
        previewTable = UITableView.init(frame: self.frame, style: UITableView.Style.grouped)
        previewTable?.delegate = self as? UITableViewDelegate
        previewTable?.dataSource = self as? UITableViewDataSource
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
