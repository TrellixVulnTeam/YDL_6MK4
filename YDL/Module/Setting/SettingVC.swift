//
//  SettingVC.swift
//  YDL
//
//  Created by ceonfai on 2019/2/13.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit

class SettingVC: BaseSetting {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return "5882"
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 80
    }

    var settingTable:UITableView?
    var languageItem:BaseItem?
    var updateItem:BaseItem?
    var updateSession:URLSession?
    let downloadLabel = UILabel()
    var dlTask = URLSessionDownloadTask()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Localized(enKey: "Settings")
        let popIcon  = FontIcon(withIcon: "\u{e6ec}", size: 40, color: .white)//返回按钮
        let leftItem = UIBarButtonItem.init(image: popIcon, style: UIBarButtonItem.Style.plain, target: self, action: #selector(popAction))
        self.navigationItem.leftBarButtonItem = leftItem
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.white]
        
        self.view.backgroundColor = .white
        
        createSettingUI()
    }
    
    func createSettingUI() -> Void {
        
        settingTable = (super.view as! UITableView)
        settingTable?.tableHeaderView = SettingHeader.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 110))
        self.addLanguageSection()
        self.addUpdateSection()
    }
    
    func addLanguageSection() -> Void{
    
        let baseItem = BaseItem()
        let languageText = Localized(enKey: LanguageReader.sharedInstance.usingLanguage())
        baseItem.setupItem(iconStr: "", titleStr: languageText, itemType: .arrow)
        languageItem = baseItem
        baseItem.operation =  ({ [weak self] () -> Void in
            self?.chooseLanguage()
        })
        let group = BaseGroup()
        group.header = Localized(enKey: "Language")
        group.items = [languageItem as Any]
        allGroups.add(group)
    }
    
    func addUpdateSection() -> Void{
        
        let baseItem = BaseItem()
        let languageText = Localized(enKey: "Resolver Library")
        baseItem.setupItem(iconStr: "", titleStr: languageText, itemType: .arrow)
        updateItem = baseItem
        baseItem.operation =  ({ [weak self] () -> Void in
            self?.updateAction()
        })
        let group = BaseGroup()
        group.header = Localized(enKey: "Update")
        group.items = [updateItem as Any]
        allGroups.add(group)
    }
    
    @objc func popAction() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func chooseLanguage() -> Void {
        
        self.navigationController?.pushViewController(LanguageSelector(), animated: true)
        
    }
    
    @objc func updateAction() -> Void {
        
        self.showUpdateProgree()
        
        self.downloadLabel.text = "--/--"
        PythonManager.shared().updateYDL(progress: { [weak self](progress) in
            
            self?.downloadLabel.text = progress
        
        }) { (isError) in
            
            DispatchQueue.main.async {
                if(isError == true) {
                    self.hideUpdateUI()
                    YDLHUD.showText(text: Localized(enKey: "Success"), delay: 1.5)
                } else {
                    
                    self.hideUpdateUI()
                    YDLHUD.showText(text: "Fail", delay: 1.5)
                }
            }
        }
    }
    
    func showUpdateProgree() -> Void {

        let window: UIWindow? = UIApplication.shared.keyWindow
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        backgroundView.backgroundColor = RGBA(R: 0, G: 0, B: 0, A: 0.8)
        let activityIndicatorView = DGActivityIndicatorView(type: .tripleRings, tintColor: RGBA(R: 0, G: 0, B: 0, A: 0.9))
        let width: CGFloat = backgroundView.bounds.size.width / 5.0
        let height: CGFloat = backgroundView.bounds.size.height / 7.0
        activityIndicatorView!.frame = CGRect(x: 0, y: 0, width: width, height: height)
        activityIndicatorView!.center = CGPoint.init(x: (window?.center.x)!, y: (window?.center.y)! - 50)
        activityIndicatorView?.tintColor = .white
        backgroundView.addSubview(activityIndicatorView!)
        activityIndicatorView!.startAnimating()
        window?.addSubview(backgroundView)
        
       
        //添加标记 方便移除
        backgroundView.tag = 23456
        activityIndicatorView!.tag = 234567
        
        self.downloadLabel.frame = CGRect.init(x: 0, y: (activityIndicatorView?.frame.origin.y)!+80, width: SCREEN_WIDTH, height: 30)
        self.downloadLabel.textColor = .white
        self.downloadLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
        self.downloadLabel.textAlignment = .center
        window?.addSubview(downloadLabel)
    }
    
    func hideUpdateUI() -> Void {
        let window: UIWindow? = UIApplication.shared.keyWindow
        let backgroundView: UIView? = window?.viewWithTag(23456)
        let activityIndicatorView = window?.viewWithTag(234567) as? DGActivityIndicatorView
        activityIndicatorView?.stopAnimating()
        backgroundView?.removeFromSuperview()
        self.downloadLabel.removeFromSuperview()
    }
}
