//
//  MediaSelector.swift
//  YDL
//
//  Created by ceonfai on 2019/1/28.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit

class SelectorCell: UITableViewCell{
    
    let playingBtn = UIButton()
    let titleView = UILabel()
    let durationView = UILabel()
    let thmView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSelectorCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSelectorCell() -> Void {
        
        self.backgroundColor = .clear
        //self.tag
        self.contentView.tag = 1800
        
        let playingImage = FontIcon(withIcon: "\u{e60d}", size: 40, color: .white)
        self.playingBtn.setImage(playingImage, for: .normal)
        self.addSubview(playingBtn)
        
        thmView.contentMode = .scaleAspectFill
        thmView.clipsToBounds = true
        self.addSubview(thmView)
        
        titleView.textColor = .white
        titleView.numberOfLines = 2
        titleView.font = UIFont.systemFont(ofSize: 10)
        self.addSubview(titleView)
        
        durationView.textColor = .white
        durationView.font = UIFont.systemFont(ofSize: 10)
        self.addSubview(durationView)

       
        playingBtn.snp.makeConstraints { (make) in
            make.left.equalTo(5)
            make.width.height.equalTo(30)
            make.centerY.equalTo(self.snp.centerY)
        }
        
        thmView.snp.makeConstraints { (make) in
            make.left.equalTo(playingBtn.snp.right)
            make.width.equalTo(45)
            make.height.equalTo(45)
            make.centerY.equalTo(self.snp.centerY)
        }
        
        titleView.snp.makeConstraints { (make) in
            make.left.equalTo(thmView.snp.right).offset(5)
            make.height.equalTo(30)
            make.top.equalTo(thmView.snp.top).offset(-5)
            make.right.equalTo(self.snp.right).offset(-20)
           
    
        }
        
        durationView.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(15)
            make.right.equalTo(self.snp.right)
            make.bottom.equalTo(self.snp.bottom)
        }
        
    }
    
    func configWithPlayingModel(dlModel:DownloadModel) -> Void {
        
        let mTitle:String  = dlModel.fileName!
        self.thmView.image = UIImage.init(data: dlModel.thmData! as Data)
        self.titleView.text = mTitle
        self.durationView.text = dlModel.duration
        
        if(MediaPlayerManager.shared.playingModel == dlModel){
            self.playingBtn.isHidden = false
        }else{
            self.playingBtn.isHidden = true
        }
    }
    
    //重写draw方法 绘制分割线
    override func draw(_ rect: CGRect) {
        let context:CGContext=UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(rect)
        context.setStrokeColor(UIColor.black.cgColor)
        //context.stroke(CGRect(x:0, y:-0.3, width: rect.size.width, height:0.3))
        context.setStrokeColor(RGBA(R: 230, G: 230, B: 230, A: 0.5).cgColor)
        context.stroke(CGRect(x:40, y: rect.size.height, width: rect.size.width, height:0.5))
    }
    
}

class MediaSelector: UIView,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate  {
 
    var selectorTable = UITableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
    
    typealias  MediaSelectorBLock = (_ index:Int) -> Void
    var selectorBlock:MediaSelectorBLock?

    override init(frame: CGRect) {
        super.init(frame: frame)
        createSelector()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSelector() -> Void {
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapToHide))
        tap.delegate = self
        self.addGestureRecognizer(tap)
        
        selectorTable.delegate = self
        selectorTable.dataSource = self
        selectorTable.backgroundColor = UIColor.clear
        selectorTable.register(SelectorCell.classForCoder(), forCellReuseIdentifier: "selectorCell")
        selectorTable.tableFooterView = UIView()
        selectorTable.tableHeaderView = UIView()
        selectorTable.separatorStyle = .none
        selectorTable.backgroundColor = RGBA(R: 0, G: 0, B: 0, A: 0.3)
        self.addSubview(selectorTable)
        
        let currentWindows: UIWindow? = UIApplication.shared.keyWindow
        self.backgroundColor = RGBA(R: 0, G: 0, B: 0, A: 0.4)
        currentWindows?.addSubview(self)
        
        self.snp.makeConstraints { (make) in
            make.left.top.width.height.equalTo(currentWindows!)
        }
        
        self.selectorTable.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.right)
            make.height.top.equalTo(self)
            make.width.equalTo(250)
        }
        
        layoutIfNeeded()//确保立即生效 防止动画从左边出现
        
        self.showSelector()
   
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (DownloadManager.shared.downloadeds?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        var selectCell:SelectorCell = tableView.dequeueReusableCell(withIdentifier: "selectorCell") as! SelectorCell
        if(selectCell.isEqual(nil)){
            selectCell = SelectorCell.init(style: .default, reuseIdentifier: "selectorCell")
        }
        selectCell.configWithPlayingModel(dlModel: DownloadManager.shared.downloadeds![indexPath.row] as! DownloadModel)
      
      
        
        return selectCell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if((self.selectorBlock) != nil){
            self.selectorBlock!(indexPath.row)
        }
    }
    
    func refreshSelector() -> Void {
        self.selectorTable.reloadData()
    }
    
    func showSelector() -> Void {
        UIView.animate(withDuration: 0.5) {
            
            self.selectorTable.snp.remakeConstraints { (make) in
                make.right.equalTo(self.snp.right)
                make.height.top.equalTo(self)
                make.width.equalTo(250)
            }
            self.layoutIfNeeded()
        }
    }
    
    func hideSelector() -> Void {
       
        
        UIView.animate(withDuration: 0.5, animations: {
            self.selectorTable.snp.remakeConstraints { (make) in
                make.left.equalTo(self.snp.right)
                make.height.top.equalTo(self)
                make.width.equalTo(250)
            }
            self.layoutIfNeeded()
            
        }) { (Bool) in
            self.removeFromSuperview()
        }
    }
    
    @objc func tapToHide()->Void{
        
        self.hideSelector()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.tag == 1800) {
            return false
        }
        return true
    }

}
