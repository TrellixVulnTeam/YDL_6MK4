//
//  MenuLinkView.swift
//  YDL
//
//  Created by ceonfai on 2019/1/10.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit

class MenuLinkView: UIView,UITableViewDelegate,UITableViewDataSource {

    typealias  MenuBlock = () -> Void
    var backgroudView:UIView?
    var menuContainView:UIView?
    var leftTable:UITableView?
    var rightTable:UITableView?
    var topView:TopView?
    var btmView:UIView?
    var recHeight:NSInteger?
    var tableViewHeight:NSInteger?
    var extKeys:NSMutableArray?
    var groupData:NSDictionary?
    var selectIndex:NSInteger?
    var mCallback:MenuBlock?
    
    func showMenu(menuData:NSDictionary) -> Void {
        
        let groupData:NSDictionary = menuData.value(forKey: "EXTGroup")as! NSDictionary
        self.extKeys = NSMutableArray.init(array: groupData.allKeys)
        self.groupData = groupData
        
        //默认选中第一个
        self.selectIndex = 0
        
        let keyWindow:UIWindow = UIApplication.shared.keyWindow!
        keyWindow.addSubview(self)
        
        //BACKGROUND
        self.backgroundColor = RGBA(R: 0, G: 0, B: 0, A: 0.5)
        self.backgroudView = UIView.init()
        let blur = UIBlurEffect.init(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView.init(effect: blur)
        blurView.frame = self.bounds
        self.addSubview(blurView)
        self.addSubview(self.backgroudView!)
        
        self.menuContainView = UIView.init()
        self.menuContainView?.backgroundColor = .white
        self.addSubview(self.menuContainView!)
        
        self.btmView = UIView.init()
        self.btmView?.backgroundColor = .white
        self.menuContainView?.addSubview(self.btmView!)
        
        //添加头
        self.topView = TopView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 130))
        self.menuContainView!.addSubview(topView!)
        self.topView?.closeCallBack = ({[weak self] in
            self!.dismissLinkView()
        })
        
        //左侧TableView
        self.leftTable = UITableView(frame: CGRect.zero, style: .plain)
        self.leftTable?.dataSource = self
        self.leftTable?.delegate = self
        self.leftTable?.estimatedRowHeight = 0
        self.leftTable?.estimatedSectionFooterHeight = 0
        self.leftTable?.estimatedSectionHeaderHeight = 0
        self.leftTable?.tableFooterView = UIView(frame: CGRect.zero)
        self.leftTable?.backgroundView?.backgroundColor = .white
        self.leftTable?.register(LeftCell.self, forCellReuseIdentifier: "LeftCell")
        self.menuContainView!.addSubview(self.leftTable!)
        
        //右侧TableView
        self.rightTable = UITableView(frame: CGRect.zero, style: .plain)
        self.rightTable!.dataSource = self
        self.rightTable!.delegate = self
        self.rightTable!.separatorStyle = .none
        let toolBar = UIToolbar(frame: self.rightTable!.frame)
        toolBar.barStyle = .default // 改变barStyle
        self.rightTable!.backgroundView = toolBar
        self.rightTable?.register(RightCell.self, forCellReuseIdentifier: "RightCell")
        self.menuContainView!.addSubview(self.rightTable!)
        
        self.leftTable!.separatorStyle = UITableViewCell.SeparatorStyle(rawValue: UITableViewCell.SelectionStyle.none.rawValue)!
        self.rightTable!.separatorStyle = UITableViewCell.SeparatorStyle(rawValue: UITableViewCell.SelectionStyle.none.rawValue)!
        self.leftTable!.showsVerticalScrollIndicator = false
        self.rightTable!.showsVerticalScrollIndicator = false
        
        self.snp .makeConstraints({ (make) in
            make.left.top.width.height.equalTo(keyWindow)
        })
        
        self.btmView?.snp.makeConstraints({ (make) in
            make.left.equalTo((self.menuContainView?.snp.left)!)
            make.bottom.equalTo((self.menuContainView?.snp.bottom)!)
            make.width.equalTo((self.menuContainView?.snp.width)!)
            make.height.equalTo(isBangDevice ?34:0)
            
        })
        
        self.leftTable?.snp.makeConstraints({ (make) in
            make.top.equalTo((self.topView?.snp.bottom)!)
            make.left.equalTo((self.backgroudView?.snp.left)!)
            make.width.equalTo(98)
            make.bottom.equalTo((self.btmView?.snp.top)!)
        })
    
        self.rightTable?.snp.makeConstraints({ (make) in
            make.top.equalTo((self.topView?.snp.bottom)!)
            make.left.equalTo((self.leftTable?.snp.right)!)
            make.right.equalTo((self.backgroudView?.snp.right)!)
            make.bottom.equalTo((self.btmView?.snp.top)!)
        })
        self.recHeight = 350
        self.backgroudView!.backgroundColor = .clear
        
        //初始位置
        self.backgroudView!.snp .makeConstraints({ (make) in
            make.left.top.width.height.equalTo(keyWindow)
        })
        self.menuContainView!.snp .makeConstraints({ (make) in
            make.left.equalTo(self.snp.left)
            make.top.equalTo(self.snp.bottom)
            make.width.equalTo(self.snp.width)
            make.height.equalTo(self.recHeight!)
        })
  
        self.layoutIfNeeded()
        //弹出位置
        UIView.animate(withDuration: 0.3, animations: {
            
            self.menuContainView?.snp.updateConstraints({ (make) in
                make.top.equalTo(self.snp.bottom).offset(-(self.recHeight)!)
            })
            self.layoutIfNeeded()
        })

       configData()
    }
    
    func configData() -> Void{
        
    }

    func dismissLinkView() -> Void {

        UIView.animate(withDuration: 0.3, animations: {
            self.menuContainView?.snp.updateConstraints({ (make) in
                make.top.equalTo(self.snp.bottom)
            })
             self.layoutIfNeeded()
        }) { (Bool) in
            self.removeFromSuperview()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.leftTable){
            return (self.extKeys?.count)!
        }
        let extKey:String = self.extKeys![self.selectIndex!] as! String
        let extData:NSArray = self.groupData?.value(forKey: extKey) as! NSArray
        return extData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(tableView == self.leftTable){
            
            var leftCell:LeftCell = tableView.dequeueReusableCell(withIdentifier: "LeftCell") as! LeftCell
            if(leftCell.isEqual(nil)){
                leftCell = LeftCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "LeftCell")
            }
            let extKey:String = self.extKeys![indexPath.row] as! String
            leftCell.setTitleText(text: extKey)
            let onSelected:Bool = indexPath.row == self.selectIndex ?true:false
            leftCell.refreshState(onClicked: onSelected)
            return leftCell
        }
        
        var rightCell:RightCell = tableView.dequeueReusableCell(withIdentifier: "RightCell") as! RightCell
        if(rightCell.isEqual(nil)){
            rightCell = RightCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "RightCell")
        }
        let extKey:String = self.extKeys![self.selectIndex!] as! String
        let extData:NSArray = self.groupData?.value(forKey: extKey) as! NSArray
       
        let formatModel:MenuModel = extData.object(at: indexPath.row) as! MenuModel
        let isMux:String = formatModel.isSpilter ?"Mux":""
        rightCell.textLabel?.text = formatModel.mResolution + "  " + formatModel.mSize + "  " + isMux
        rightCell.configModel(menuModel: formatModel)
       
        rightCell.dlCallback = ({[weak self] in
            self!.dismissLinkView()
            if(self?.mCallback != nil){
                self!.mCallback!()
            }
        })
        return rightCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(tableView == self.leftTable){
           self.selectIndex = indexPath.row
           self.leftTable?.reloadData()
           self.rightTable?.reloadData()
        }
    }
}
