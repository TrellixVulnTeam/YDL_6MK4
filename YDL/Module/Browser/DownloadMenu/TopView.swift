//
//  TopView.swift
//  YDL
//
//  Created by ceonfai on 2019/1/10.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit
import NetworkExtension

class TopView: UIView {

    typealias  TopViewbBLock = () -> Void
    var topBarView:UIView?
    var closeButton:UIButton?
    var thumbView:UIImageView?
    var titleView:UILabel?
    var paramView:UILabel?
    var closeCallBack:TopViewbBLock?
    var placeholder:UIImage? = {
        return FontIcon(withIcon: "\u{e65c}", size: 60, color: .darkGray)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        creatView()
    }
    
    func creatView() -> Void {
        
        self.topBarView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 45))
        self.topBarView!.backgroundColor = RGBA(R: 255, G: 255, B: 255, A: 0.6)
        addSubview(self.topBarView!)
        
        let blur = UIBlurEffect(style: .dark)
        let effe = UIVisualEffectView(effect: blur)
        effe.frame = self.topBarView!.bounds
        self.topBarView!.addSubview(effe)
        
        let closeOffset = frame.size.width-(IsIPad ?75:50 as CGFloat)
        let closeFrame = CGRect(x: closeOffset, y: 0, width: 50, height: 45)
        self.closeButton = UIButton.init(frame: closeFrame)
        let closeIcon = FontIcon(withIcon: "\u{e6eb}", size: 40, color: .white)
        self.closeButton?.setImage(closeIcon, for: .normal)
        self.closeButton!.addTarget(self, action: #selector(onClickClose), for: .touchUpInside)
        self.closeButton!.alpha = 0.8
        self.topBarView!.addSubview(closeButton!)
        
        
        let detailView = UIView(frame: CGRect(x: 0, y: 45, width: frame.size.width, height: frame.size.height - 45))
        detailView.backgroundColor = .white
        detailView.layer.masksToBounds = false
        detailView.layer.shadowOpacity = 1
        detailView.layer.shadowOffset = CGSize.init(width: -5, height: 5.0);
        detailView.layer.shadowRadius = 10
        self.addSubview(detailView)
        
        //===================缩略图===========================
        self.thumbView = UIImageView()
        self.thumbView!.layer.masksToBounds = true //没这句话它圆不起来
        self.thumbView!.contentMode = .scaleAspectFill
        self.thumbView!.image = self.placeholder
        detailView.addSubview(self.thumbView!)
        //====================文件名==========================
        self.titleView = UILabel()
        self.titleView!.font = UIFont.systemFont(ofSize: 13.0)
        self.titleView!.textColor = .darkGray
        self.titleView!.backgroundColor = .clear
        self.titleView!.textAlignment = .left
        self.titleView!.lineBreakMode = .byTruncatingMiddle //截去中间
        self.titleView!.numberOfLines = 3
        detailView.addSubview(self.titleView!)
        
        self.paramView = UILabel()
        self.paramView!.font = UIFont.systemFont(ofSize: 13.0)
        self.paramView!.textColor = .lightGray
        self.paramView!.backgroundColor = .clear
        self.paramView!.textAlignment = .left
        detailView.addSubview(self.paramView!)
        
        let thnHeight: Int = Int(frame.size.height - 16 - 45)
        let thnWidth = Int(Double(thnHeight) * 1.3)
        
        self.thumbView?.snp.makeConstraints({ (make) in
            make.left.equalTo(8)
            make.top.equalTo(8)
            make.width.equalTo(thnWidth)
            make.height.equalTo(thnHeight);
        })
        
        self.titleView?.snp.makeConstraints({ (make) in
            make.left.equalTo(self.thumbView!.snp.right).offset(8);
            make.top.equalTo(0);
            make.right.equalTo(self.snp.right).offset(-15);
            make.height.equalTo(50);
        })
        
        self.paramView?.snp.makeConstraints({ (make) in
            make.left.equalTo((self.titleView?.snp.left)!)
            make.top.equalTo((self.titleView?.snp.bottom)!);
            make.right.equalTo(self.snp.right).offset(-15);
            make.height.equalTo(25);
        })
        
    }
    
    func configWithOriginData(parseResult:NSDictionary) -> Void {
      
      let mTitle:String  = parseResult.value(forKey: "title")as!String
      let mCount:Int     = parseResult.value(forKey: "all")as!Int
      let mTHMURL:String = parseResult.value(forKey: "thumbnailURL")as!String
      let thumbURL = URL.init(string: mTHMURL)
      self.thumbView?.kf.setImage(with: thumbURL)
      self.titleView?.text = mTitle
      self.paramView?.text = String.init(format: "视频数量:%zd", mCount)
    }
    
    @objc func onClickClose()->Void{
        if(self.closeCallBack != nil){
            self.closeCallBack!()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
