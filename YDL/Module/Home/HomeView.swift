//
//  HomeView.swift
//  YDL
//
//  Created by ceonfai on 2019/1/7.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit

class HomeView: UIView,UITableViewDataSource,UITableViewDelegate {
    
    var homeTable:UITableView?
    var isInEdit:Bool?//是否正在编辑
    var editData:NSMutableArray?//是否正在编辑
    var emptyView:UIView?
    var transView:TransmissionView?
    
    typealias  HomeViewBLock = (_ index:Int) -> Void
    var fileClickCallBack:HomeViewBLock?
    var fileDeleteCallBack:HomeViewBLock?
    var fileTransmissionCallBack:HomeViewBLock?
    var fileMoreActionCallBack:HomeViewBLock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTableView()
    }
    
    func setupTableView() -> Void {
        homeTable = UITableView.init(frame: self.frame, style: UITableView.Style.plain)
        homeTable?.dataSource = self
        homeTable?.delegate = self
        homeTable?.backgroundColor = .white
        homeTable?.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.addSubview(homeTable!)
        
        emptyView = self.createEmptyView()
        
        transView = TransmissionView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 95))
        transView?.touchAreaCallBack = {
            if (self.fileTransmissionCallBack != nil) {
                self.fileTransmissionCallBack!(0)
            }
        }
        refreshTransmissHeaderState()
    }
    
    func refreshTransmissHeaderState() {
        
        if DownloadManager.shared.downloadings!.count > 0 {
            homeTable!.tableHeaderView = transView
        } else {
            homeTable!.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: bounds.size.width, height: 0.01))
            homeTable!.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: bounds.size.width, height: 0.01))
        }
        
        if(DownloadManager.shared.downloadingModel != nil){
            self.transView!.operationBtn.isSelected = false
        }else{
            self.transView!.operationBtn.isSelected = true
            
        }
        
    }
    
    func createEmptyView() -> UIView {
        
        let emptyView = UIView()
        self.homeTable?.addSubview(emptyView)
        
        let emptyImageView = UIImageView()
        emptyImageView.image = FontIcon(withIcon: "\u{e6e3}", size: 80, color: .darkGray)
        emptyView.addSubview(emptyImageView)
        
        let emptyText = UILabel()
        emptyText.text = Localized(enKey: "No Media")
        emptyText.textColor = .darkGray
        emptyText.textAlignment = .center
        emptyView.addSubview(emptyText)
        
        emptyView.snp.makeConstraints { (make) in
            make.centerX.equalTo((self.homeTable?.snp.centerX)!)
            make.centerY.equalTo((self.homeTable?.snp.centerY)!).offset(-80)
            make.width.equalTo(100)
            make.height.equalTo(110)
        }
        emptyImageView.snp.makeConstraints { (make) in
            make.top.equalTo(emptyView.snp.top)
            make.centerX.equalTo(emptyView.snp.centerX)
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
        emptyText.snp.makeConstraints { (make) in
            make.top.equalTo(emptyImageView.snp.bottom)
            make.left.equalTo(emptyView.snp.left)
            make.width.equalTo(emptyView.snp.width)
            make.height.equalTo(30)
        }
        
        return emptyView
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        emptyView?.isHidden = (DownloadManager.shared.downloadeds?.count)! > 0 ?true:false
        return (DownloadManager.shared.downloadeds?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var preCell = tableView.dequeueReusableCell(withIdentifier: "preViewCell")
        if preCell == nil {
            preCell = PreviewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "preViewCell")
        }
        let dlModel = DownloadManager.shared.downloadeds?.object(at: indexPath.row) as! DownloadModel
        (preCell as! PreviewCell).configOnlineData(dataM:dlModel)
        
        (preCell as! PreviewCell).moreActionCallBack = ({[weak self] () -> Void in
            
            if(self?.fileMoreActionCallBack != nil){
                self?.fileMoreActionCallBack!(indexPath.row)
            }
            
        })
        
        return preCell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return Localized(enKey: "Delete")
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if((self.fileDeleteCallBack) != nil){
            self.fileDeleteCallBack!(indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if((self.fileClickCallBack) != nil){
            self.fileClickCallBack!(indexPath.row)
        }
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
