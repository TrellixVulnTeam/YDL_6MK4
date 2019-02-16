//
//  DownloadingCell.swift
//  YDL
//
//  Created by ceonfai on 2019/1/22.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit

class DownloadingCell: UITableViewCell {

    var thmView:UIImageView?
    var nameView:UILabel?
    var sizeView:UILabel?
    var remainView:UILabel?
    var speedView:UILabel?
    var progressView:KYCircularProgress?
    var downloadModel:DownloadModel?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        NotificationCenter.default.addObserver(self, selector: #selector(downloadStateUpdate), name: NSNotification.Name(rawValue:"DL_STATE"), object: nil)
        createDownloadingCell()
    }
    
    func createDownloadingCell() -> Void {
        
        self.selectionStyle = .none
        
        thmView      = UIImageView()
        nameView     = UILabel()
        sizeView     = UILabel()
        speedView    = UILabel()
        remainView   = UILabel()
        progressView = KYCircularProgress(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
        
        thmView?.contentMode = UIView.ContentMode.scaleAspectFill
        thmView?.layer.masksToBounds = true
        
        nameView!.textColor = UIColor.darkGray
        nameView!.font = UIFont.systemFont(ofSize: 14.0)
        nameView!.lineBreakMode = .byTruncatingMiddle //截去中间
        
        speedView?.textColor = UIColor.lightGray
        speedView?.font = UIFont.systemFont(ofSize: 12.0)
        speedView?.textAlignment = .right
        speedView?.isHidden = true
        speedView?.textColor = UIColor.lightGray
        speedView?.font = UIFont.systemFont(ofSize: 12.0)

        sizeView?.font = UIFont.systemFont(ofSize: 12.0)
        sizeView?.textColor = .lightGray
        
        // support Hex color to RGBA color
        progressView!.colors = [UIColor(rgba: 0xA6E39D11), UIColor(rgba: 0xAEC1E355), UIColor(rgba: 0xAEC1E3AA), UIColor(rgba: 0xF3C0ABFF)]
        
        // combine Hex color and UIColor
        progressView!.colors = [.purple, UIColor(rgba: 0xFFF77A55), .orange]
        
        self.addSubview(thmView!)
        self.addSubview(nameView!)
        self.addSubview(sizeView!)
        self.addSubview(speedView!)
        self.addSubview(remainView!)
        self.addSubview(progressView!)
        
        thmView?.snp.makeConstraints({ (make) in
            make.left.equalTo(15)
            make.centerY.equalTo(self.snp.centerY)
            make.width.equalTo(40)
            make.height.equalTo(40)
        })
        
        progressView?.snp.makeConstraints({ (make) in
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.right.equalTo(self.snp.right).offset(-10)
            make.centerY.equalTo(self.snp.centerY)
        })
        
        speedView?.snp.makeConstraints({ (make) in
            make.width.equalTo(70);
            make.height.equalTo(30);
            make.right.equalTo(self.snp.right).offset(-10);
            make.centerY.equalTo(self.snp.centerY);
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
    
    @objc func downloadStateUpdate(notify:NSNotification)->Void{
        if(self.downloadModel != DownloadManager.shared.downloadingModel){
            return
        }
        let task = notify.object as! TRTask
        sizeView?.text = "\(task.progress.completedUnitCount.tr.convertBytesToString())/\(task.progress.totalUnitCount.tr.convertBytesToString())"
        speedView?.text = task.speed.tr.convertSpeedToString()
        progressView?.progress = task.progress.fractionCompleted
        print(sizeView?.text as Any)
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
        if(dlModel == DownloadManager.shared.downloadingModel){
            self.progressView?.isHidden = false
        }else{
            self.progressView?.isHidden = true
            self.sizeView?.text = "等待中..."
        }
        let thumbURL = URL.init(string: dlModel.thmURL!)
        self.thmView?.kf.setImage(with: thumbURL)
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
