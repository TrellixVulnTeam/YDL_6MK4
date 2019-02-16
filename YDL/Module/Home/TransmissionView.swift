//
//  TransmissionView.swift
//  YDL
//
//  Created by ceonfai on 2019/2/14.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit

class TransmissionView: UIView {

    var operationBtn: UIButton = UIButton()
    var title: UILabel = UILabel()
    var queueLabel: UILabel = UILabel()
    var sentLabel: UILabel = UILabel()
    var speedLabel: UILabel = UILabel()
    var backgroundView: UIView = UIView()
    var thumbView: UIImageView = UIImageView()
    var touchArea: UIButton = UIButton()
    var progressView:KYCircularProgress?
    
    typealias  TransmissionViewBLock = () -> Void
    var touchAreaCallBack:TransmissionViewBLock?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(upadteDownloadStatus), name: NSNotification.Name("DL_STATE"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(upadteDownloadQueue), name: NSNotification.Name("refreshQueue"), object: nil)
        
        self.createTransmissionView()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createTransmissionView()->Void{
    
        
        backgroundColor = RGBA(R: 245, G: 245, B: 245, A: 1.0)
        layer.masksToBounds = true //不显示超出部分
        
        backgroundView.backgroundColor = .white
        addSubview(backgroundView)
        
        title.font = UIFont.systemFont(ofSize: 13.0)
        title.text = "正在下载"
        title.textColor = UIColor.darkGray
        title.backgroundColor = UIColor.clear
        addSubview(title)
        
        thumbView.image = UIImage.init(named: "placeholder")
        thumbView.contentMode = .scaleAspectFill
        thumbView.clipsToBounds = true
        backgroundView.addSubview(thumbView)
        
        queueLabel.font = UIFont.systemFont(ofSize: 13.0)
        queueLabel.numberOfLines = 2
        queueLabel.text = "任务已暂停"
        queueLabel.textColor = UIColor.black
        backgroundView.addSubview(queueLabel)
        
        sentLabel.text = "--/--"
        sentLabel.font = UIFont.systemFont(ofSize: 12.0)
        sentLabel.textColor = UIColor.darkGray
        backgroundView.addSubview(sentLabel)
        
        speedLabel.isHidden = true
        speedLabel.textAlignment = .right
        speedLabel.textColor = UIColor.lightGray
        speedLabel.font = UIFont.systemFont(ofSize: 12.0)
        backgroundView.addSubview(speedLabel)
        
        touchArea = UIButton(frame: bounds)
        touchArea.addTarget(self, action: #selector(onClickTouchArea), for: .touchUpInside)
        addSubview(touchArea)
        
        operationBtn = UIButton()
        //_operationBtn.frame = CGRectMake(self.frame.size.width - 95, 10,80, 50-20)
        operationBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        
        operationBtn.setTitleColor(UIColor.darkGray, for: .normal)
        operationBtn.backgroundColor = UIColor.white
        operationBtn.setImage(FontIcon(withIcon: "\u{e629}", size: 60, color: .gray), for: .normal)
        operationBtn.setImage(FontIcon(withIcon: "\u{e730}", size: 60, color: .gray), for: .selected)
        operationBtn.setTitleColor(UIColor.black, for: .normal)
        operationBtn.addTarget(self, action: #selector(onClickOperationBtn), for: .touchUpInside)
        operationBtn.isSelected = true
        addSubview(operationBtn)
        
        //初始化数据
        self.upadteDownloadQueue()
        
        title.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(15)
            make.top.equalTo(self.snp.top).offset(5)
            make.width.equalTo(150)
            make.height.equalTo(20)
        }
        
  
        
        backgroundView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left)
            make.top.equalTo(self.title.snp.bottom).offset(5)
            make.width.equalTo(self.snp.width)
            make.height.equalTo(60)
            }
        thumbView.snp.makeConstraints { (make) in
            make.left.equalTo(self.backgroundView.snp.left).offset(15)
            make.top.equalTo(self.backgroundView.snp.top).offset(5)
            make.width.height.equalTo(50)
            
            }
        queueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.thumbView.snp.right).offset(8)
            make.top.equalTo(self.thumbView.snp.top)
            make.right.equalTo(self.operationBtn.snp.left).offset(-10)
            make.height.equalTo(35)
            }
        sentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.thumbView.snp.right).offset(8)
            make.top.equalTo(self.queueLabel.snp.bottom)
            make.right.equalTo(self.operationBtn.snp.left).offset(-10)
            make.height.equalTo(15)
            }
        
        operationBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.backgroundView.snp.right).offset(-15)
            make.width.height.equalTo(40)
            make.centerY.equalTo(self.backgroundView.snp.centerY)
            }
        
        speedLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.operationBtn.snp.left).offset(-8)
            make.top.equalTo(self.queueLabel.snp.bottom)
            make.right.equalTo(self.operationBtn.snp.left).offset(-10)
            make.height.equalTo(25)
            }

    }
    
    @objc func upadteDownloadStatus(_ notify: Notification?) {
        
        let task = notify!.object as! TRTask
        sentLabel.text = "\(task.progress.completedUnitCount.tr.convertBytesToString())/\(task.progress.totalUnitCount.tr.convertBytesToString())"
        speedLabel.text = task.speed.tr.convertSpeedToString()
        progressView?.progress = task.progress.fractionCompleted
    }
    
    @objc func upadteDownloadQueue(){

        if(DownloadManager.shared.downloadings?.count == 0){
            return;
        }
        title.text = Localized(enKey: "Remain") + String.init(format: "%zd", (DownloadManager.shared.downloadings?.count)!)
        let downloadModel = DownloadManager.shared.downloadings?.firstObject as! DownloadModel
        thumbView.kf.setImage(with: URL.init(string: downloadModel.thmURL!))
        queueLabel.text = downloadModel.fileName
    }

    @objc func onClickOperationBtn(_ sender: UIButton?) {
        
        sender?.isSelected = !(sender?.isSelected)!
        
        if sender?.isSelected == true {
            DownloadManager.shared.pauseDownload()
        } else {
            DownloadManager.shared.resumeDL()
        }
        self.upadteDownloadQueue()
    }
    
    @objc func onClickTouchArea()->Void {
        if ((self.touchAreaCallBack) != nil) {
            touchAreaCallBack!()
        }
    }
    
    @objc func delayHiddenSpeed() {
        speedLabel.isHidden = true
    }


}
