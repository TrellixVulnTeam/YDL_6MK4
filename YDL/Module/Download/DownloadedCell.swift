//
//  DownloadedCell.swift
//  YDL
//
//  Created by ceonfai on 2019/1/22.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit

class DownloadedCell: UITableViewCell {

    var thmView:UIImageView?
    var nameView:UILabel?
    var sizeView:UILabel?
    var downloadModel:DownloadModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createDownloadedCell()
    }
    
    func createDownloadedCell() -> Void {
        
        self.selectionStyle = .none
        
        thmView      = UIImageView()
        nameView     = UILabel()
        sizeView     = UILabel()
    
        
        thmView?.contentMode = UIView.ContentMode.scaleAspectFill
        thmView?.layer.masksToBounds = true
        
        nameView!.textColor = UIColor.darkGray
        nameView!.font = UIFont.systemFont(ofSize: 14.0)
        nameView!.lineBreakMode = .byTruncatingMiddle //截去中间
        
        sizeView?.font = UIFont.systemFont(ofSize: 12.0)
        sizeView?.textColor = .lightGray
        
        self.addSubview(thmView!)
        self.addSubview(nameView!)
        self.addSubview(sizeView!)
        
        thmView?.snp.makeConstraints({ (make) in
            make.left.equalTo(15)
            make.centerY.equalTo(self.snp.centerY)
            make.width.equalTo(40)
            make.height.equalTo(40)
        })
    
        nameView?.snp.makeConstraints({ (make) in
            make.top.equalTo((thmView?.snp.top)!);
            make.left.equalTo((thmView?.snp.right)!).offset(8);
            make.right.equalTo(self.snp.right).offset(-70);
            make.height.equalTo(20);
        })
        
        sizeView?.snp.makeConstraints({ (make) in
            make.top.equalTo((nameView?.snp.bottom)!);
            make.left.equalTo((thmView?.snp.right)!).offset(8);
            make.width.equalTo(150);
            make.height.equalTo(20);
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configWithModel(dlModel:DownloadModel) -> Void {
        self.downloadModel = dlModel
        nameView?.text = dlModel.fileName
        thmView!.image = UIImage.init(data: dlModel.thmData! as Data)
        self.sizeView?.text = String.init(format: "%@ %@", dlModel.size ?? "未知大小", dlModel.resolution ?? "未知分辨率")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    deinit {
        /// 移除通知
        NotificationCenter.default.removeObserver(self)
    }

}
