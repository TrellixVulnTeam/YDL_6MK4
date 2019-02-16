//
//  PreviewCell.swift
//  zTube
//
//  Created by ceonfai on 2018/12/27.
//  Copyright © 2018 Leawo. All rights reserved.
//

import UIKit


class PreviewCell: UITableViewCell {

    var checkImage:UIImage?//复选框选中图片
    var uncheckImage:UIImage?//复选框取消选中图片
    var thumbView:UIImageView?//文件缩略图
    var fileTitleLabel:UILabel?//文件标题
    var fileDateLabel:UILabel?//文件日期
    var fileParamLabel:UILabel?//日期下面的文件参数
    var thmMaskView:UIView?//缩略图的半透明遮罩
    var durationLabel:UILabel?//文件时长
    var formatLabel:UILabel?//文件格式
    var funcBtn:UIButton?//操作按钮
    var checkView:UIImageView?//复选框
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        CreateListCell()
    }
    
    func setupOnlineData(dataM:DownloadModel) -> Void {
        
        self.thumbView?.image = UIImage.init(named: "picture-T")
//        self.fileTitleLabel?.text = dataM.fileName?.deletingPathExtension
//        self.formatLabel?.text = dataM.fileName?.pathExtension
//        self.fileDateLabel?.text = dataM.fileDate?.appending("");
    }
    
    func CreateListCell() -> Void {
        
        //初始化
        self.thumbView = UIImageView.init()
        self.fileTitleLabel = UILabel.init()
        self.fileDateLabel = UILabel.init()
        self.fileParamLabel = UILabel.init()
        self.thmMaskView = UIView.init()
        self.durationLabel = UILabel.init()
        self.formatLabel = UILabel.init()
        self.funcBtn = UIButton.init()
        self.checkView = UIImageView.init()
        
        //添加至视图上
        self.addSubview(self.thumbView!)
        self.addSubview(self.fileTitleLabel!)
        self.addSubview(self.fileDateLabel!)
        self.addSubview(self.fileParamLabel!)
        self.addSubview(self.thmMaskView!)
        self.addSubview(self.durationLabel!)
        self.addSubview(self.formatLabel!)
        self.addSubview(self.funcBtn!)
        self.addSubview(self.checkView!)
        
        //配置参数
        self.thumbView?.image = UIImage.init(named: "picture-T")
        self.thmMaskView?.backgroundColor = UIColor.init(red: 0, green:0 , blue: 0, alpha: 0.5)
        
        self.fileTitleLabel!.textColor = UIColor.darkGray
        self.fileTitleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.fileParamLabel?.lineBreakMode = NSLineBreakMode.byTruncatingMiddle
        self.fileTitleLabel!.numberOfLines = 2
        
        self.fileDateLabel!.textColor = UIColor.lightGray
        self.fileDateLabel?.font = UIFont.systemFont(ofSize: 12)
        
        self.fileParamLabel!.textColor = UIColor.lightGray
        self.fileParamLabel?.font = UIFont.systemFont(ofSize: 12)
        
        self.durationLabel!.textColor = UIColor.white
        self.durationLabel?.font = UIFont.systemFont(ofSize: 11)
        self.formatLabel?.textAlignment = NSTextAlignment.left
        
        self.formatLabel!.textColor = UIColor.white
        self.formatLabel?.font = UIFont.systemFont(ofSize: 11)
        self.formatLabel?.textAlignment = NSTextAlignment.right
       /*
        //约束
        self.thumbView?.snp.makeConstraints({ (make) in
            make.left.equalTo(15)
            make.centerY.equalTo(self.snp.centerY)
            make.width.equalTo(120)
            make.height.equalTo(90)
        })
        
        self.thmMaskView?.snp.makeConstraints({ (make) in
            make.left.equalTo(self.thmMaskView!.snp.left)
            make.bottom.equalTo(self.thmMaskView!.snp.bottom)
            make.right.equalTo(self.thmMaskView!.snp.right)
            make.height.equalTo(15)
        })
        
        self.fileTitleLabel?.snp.makeConstraints({ (make) in
            make.left.equalTo((self.thumbView?.snp.right)!).offset(8)
            make.top.equalTo((self.thumbView?.snp.top)!).offset(-8);
            make.right.equalTo(self.snp.right).offset(-8);
            make.height.equalTo(50);
        })
        
        self.fileDateLabel?.snp.makeConstraints({ (make) in
            make.left.equalTo((self.thumbView?.snp.right)!).offset(8);
            make.top.equalTo(self.fileTitleLabel!.snp.bottom);
            make.right.equalTo(self.fileTitleLabel!.snp.right);
            make.height.equalTo(25);
        })
        
        self.fileParamLabel?.snp.makeConstraints({ (make) in
            make.left.equalTo((self.thumbView?.snp.right)!).offset(8);
            make.top.equalTo(self.fileDateLabel!.snp.bottom);
            make.right.equalTo(self.fileTitleLabel!.snp.right);
            make.height.equalTo(25);
        })
        
        self.thmMaskView?.snp.makeConstraints({ (make) in
            make.left.equalTo((self.thumbView?.snp.left)!)
            make.bottom.equalTo((self.thumbView?.snp.bottom)!)
            make.right.equalTo((self.thumbView?.snp.right)!);
            make.height.equalTo(15);
        })
        
        self.formatLabel?.snp.makeConstraints({ (make) in
            make.left.equalTo((self.thumbView?.snp.left)!);
            make.bottom.equalTo(self.thumbView!.snp.bottom);
            make.right.equalTo(self.thumbView!.snp.right).offset(-5);
            make.height.equalTo(15);
        })
        
        self.durationLabel?.snp.makeConstraints({ (make) in
            make.left.equalTo((self.thumbView?.snp.left)!);
            make.bottom.equalTo(self.thumbView!.snp.bottom);
            make.right.equalTo(self.thumbView!.snp.right).offset(-5);
            make.height.equalTo(15);
        })
        
        self.funcBtn?.snp.makeConstraints({ (make) in
            make.width.equalTo(40);
            make.bottom.equalTo(self.thumbView!.snp.bottom);
            make.right.equalTo(self.thumbView!.snp.right).offset(-5);
            make.height.equalTo(15);
        })
        
        self.checkView?.snp.makeConstraints({ (make) in
            make.width.equalTo(30);
            make.bottom.equalTo(self.thumbView!.snp.bottom);
            make.right.equalTo(self.thumbView!.snp.right).offset(-5);
            make.height.equalTo(30);
        })
 
 */
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //重写draw方法 绘制分割线
    override func draw(_ rect: CGRect) {
        let context:CGContext=UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(rect)
        context.setStrokeColor(UIColor.black.cgColor)
        context.stroke(CGRect(x:0, y:-0.3, width: rect.size.width, height:0.3))
        context.setStrokeColor(UIColor.black.cgColor)
        context.stroke(CGRect(x:0, y: rect.size.height, width: rect.size.width, height:0.3))
    }


}
