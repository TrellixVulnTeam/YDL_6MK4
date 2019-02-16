//
//  RightCell.swift
//  YDL
//
//  Created by ceonfai on 2019/1/10.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit

class RightCell: UITableViewCell {

    typealias  RightCellBlock = () -> Void
    var downloadBtn:UIButton?
    var mModel:MenuModel?
    var dlCallback:RightCellBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        configUI()
    }
    
    func configModel(menuModel:MenuModel) -> Void {
        self.mModel = menuModel
    }
    
    func configUI() -> Void {
        
        self.textLabel?.font = UIFont(name: "TimesNewRomanPS-BoldMT", size: CGFloat(13))
        self.textLabel?.textColor = .darkGray
        
        let downloadIcon = FontIcon(withIcon: "\u{e6be}", size: 40, color: .darkGray)
        self.downloadBtn = UIButton.init(type: UIButton.ButtonType.custom)
        self.downloadBtn?.setImage(downloadIcon, for: UIControl.State.normal)
        self.downloadBtn?.addTarget(self, action: #selector(onClickDownload), for: .touchUpInside)
        self.addSubview(self.downloadBtn!)
        
        self.downloadBtn?.snp.makeConstraints({ (make) in
            make.right.equalTo(self.snp.right).offset((IsIPad ? -30: -15))
            make.width.height.equalTo(50)
            make.centerY.equalTo(self.snp.centerY)
        })
    }
    
    @objc func onClickDownload()->Void{
        
        DownloadManager.shared.addVideoDL(menuModel: self.mModel!)
        if(self.dlCallback != nil){
            self.dlCallback!()
        }
    }
    
    func setTitleText(text:String) -> Void {
        self.textLabel?.text = text
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
