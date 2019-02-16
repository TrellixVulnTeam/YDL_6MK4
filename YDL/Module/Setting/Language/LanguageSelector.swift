//
//  LanguageSelector.swift
//  YDL
//
//  Created by ceonfai on 2019/2/14.
//  Copyright © 2019 Leawo. All rights reserved.
//

import UIKit

class LanguageSelector: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var tableView = UITableView.init(frame: CGRect.zero, style: .plain)
    var languageList = NSMutableArray()
    var saveBtn = UIButton()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.languageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "kLanguageCell") as? LanguageCell
        if cell == nil {
             cell = LanguageCell(style: .default, reuseIdentifier: "kLanguageCell")
        }
        let model: LanguageModel? = (languageList[indexPath.row] as! LanguageModel)
        cell?.accessoryType = model?.enabled != false ? .checkmark : .none
        cell?.reset(withData: model)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        for i in 0..<languageList.count {
            let model: LanguageModel? = (languageList[i] as! LanguageModel)
            model?.enabled = indexPath.row == i
        }
        self.tableView.reloadData()
    }

    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = Localized(enKey: "Language")
        let popIcon  = FontIcon(withIcon: "\u{e6ec}", size: 40, color: .white)//返回按钮
        let leftItem = UIBarButtonItem.init(image: popIcon, style: UIBarButtonItem.Style.plain, target: self, action: #selector(popAction))
        self.navigationItem.leftBarButtonItem = leftItem
        
        setupLanguageList()
        
        setupUI()
 
    }
    
    func setupUI() -> Void {
        
        self.view.backgroundColor = .white
        
        saveBtn.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 60)
        saveBtn.backgroundColor = UIColor.white
        saveBtn.setTitleColor(RGBA(R: 130, G: 133, B: 139, A: 1.0), for: .normal)
        saveBtn.setTitle(Localized(enKey: "Change"), for: .normal)
        saveBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        saveBtn.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        self.view.addSubview(saveBtn)
        
        tableView.backgroundColor = UIColor.groupTableViewBackground
        tableView.separatorStyle = .none
        tableView.tableFooterView = saveBtn
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.snp.left)
            make.top.equalTo(self.view.snp.top)
            make.width.equalTo(self.view.snp.width)
            make.height.equalTo(self.view.snp.height)
        }

    }
    
    func setupLanguageList() -> Void {

        let languageBundle = Bundle.init(path: Bundle.main.path(forResource: "Language", ofType: "bundle")!)!
        let path = languageBundle.path(forResource: "languageList", ofType: "json")
        
        let jsonData = try?Data.init(contentsOf: URL.init(fileURLWithPath: path!))
        let jsonArray:NSArray = try! JSONSerialization.jsonObject(with: jsonData!, options: .allowFragments) as! NSArray
        
        let currentLanguage = LanguageReader.sharedInstance.usingLanguage()
       
        for index in 0...(jsonArray.count-1){
            let oneItem = jsonArray[index] as! NSDictionary
            let languageModel = LanguageModel()
            languageModel.title = oneItem["title"] as! String
            languageModel.enabled = false
            languageModel.key = oneItem["key"] as! String
            
            if(languageModel.key.caseInsensitiveCompare(currentLanguage).rawValue == 0){
                languageModel.enabled = true
            }
            self.languageList.add(languageModel)
        }

        
       
    }
    
    @objc func popAction() -> Void {
        self.navigationController?.popViewController(animated: true)
    }


    
    @objc func saveButtonAction(_ sender: Any?) {
        let key = getCurrentKey()
        let currentLanguage = LanguageReader.sharedInstance.usingLanguage()
        if key != "" && !(key == currentLanguage) {
            //[self showHUD:NSLocalizedString(@"更换语言中...", nil)];
            //这里延时是为了让用户觉得我们确实在费力的切换语言，不然很突兀
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                //@strongify(self);
                self.changeLanguage(forKey: key)
            })
        } else {
            
        }
    }


    func changeLanguage(forKey key: String?) {
        //[self hideHUD];
        navigationController?.popToRootViewController(animated: true)
        LanguageReader.sharedInstance.toUseLanguage(languageKey: key!) //将新的语言标示存入本地
        //NSString *language=[[DLocalized sharedInstance]currentLanguage];
        //NSLog(@"切换后的语言:%@",language);
        //延时操作，等POP动画结束
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            //self.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: NSNotification.Name("kNotifyRootViewControllerReset"), object: nil) //发送刷新页面通知
        })
    }
    
    func getCurrentKey() -> String? {
        var key: String?
        for i in 0..<languageList.count {
            let model: LanguageModel? = (languageList[i] as! LanguageModel)
            if (languageList[i] as! LanguageModel).enabled == true {
                key = model?.key ?? ""
            }
        }
        return key
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
