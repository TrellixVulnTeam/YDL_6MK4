//
//  DownloadVC.swift
//  YDL
//
//  Created by ceonfai on 2019/1/22.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit

class DownloadVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var downloadTable:UITableView?
    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshQueue), name: NSNotification.Name(rawValue:"refreshQueue"), object: nil)
    }
    
    func createView() -> Void {
        
        self.title = Localized(enKey: "Downloaded")
        let popIcon  = FontIcon(withIcon: "\u{e6ec}", size: 40, color: .white)//返回按钮
        let leftItem = UIBarButtonItem.init(image: popIcon, style: UIBarButtonItem.Style.plain, target: self, action: #selector(popAction))
        self.navigationItem.leftBarButtonItem = leftItem
  
        
        downloadTable = UITableView.init(frame: self.view.frame, style: UITableView.Style.plain)
        downloadTable?.delegate = self
         downloadTable?.dataSource = self
        downloadTable?.backgroundColor = .white
        downloadTable?.separatorStyle = UITableViewCell.SeparatorStyle.none
        downloadTable?.register(DownloadingCell.self, forCellReuseIdentifier: "DownloadingCell")
        downloadTable?.register(DownloadedCell.self, forCellReuseIdentifier: "DownloadedCell")
        self.view.addSubview(downloadTable!)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    @objc func popAction() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return DownloadManager.shared.downloadings!.count
        }
        return DownloadManager.shared.downloadeds!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //下载中
        if indexPath.section == 0 {
            let downloadingCell = tableView.dequeueReusableCell(withIdentifier: "DownloadingCell") as? DownloadingCell
            let downloadingM = DownloadManager.shared.downloadings?.object(at: indexPath.row) as! DownloadModel
            downloadingCell!.configWithModel(dlModel: downloadingM)
            return downloadingCell!
        }
        //已下载
        let downloadedCell = tableView.dequeueReusableCell(withIdentifier: "DownloadedCell") as! DownloadedCell
        let downloadedM = DownloadManager.shared.downloadeds?.object(at: indexPath.row) as! DownloadModel
        downloadedCell.configWithModel(dlModel: downloadedM)
        return downloadedCell

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 35)
        let header = DownloadHeader.init(frame:frame)
        header.updateTitle(section == 0 ? Localized(enKey: "Downloading"):Localized(enKey: "Downloaded"))
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        //play
        if(indexPath.section == 1){
            
            let mediaVC = MediaPlayerVC()
            mediaVC.setupPlayer(playQueue: DownloadManager.shared.downloadeds!, playIndex: indexPath.row)
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.allowRotation = true
            mediaVC.beginSupportLanscape()
            self.present(mediaVC, animated:true, completion: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        //delete Task
        if(indexPath.section == 0){
            
            let downloadModel = DownloadManager.shared.downloadings![indexPath.row] as! DownloadModel
            
            if(downloadModel == DownloadManager.shared.downloadingModel){
                TRManager.default.totalRemove()
                //删除真实文件
                DownloadManager.shared.downloadingModel = nil
            }
            DownloadManager.shared.downloadings?.removeObject(at: indexPath.row)
            //coredata remove
            DownloadManager.shared.downloadeds?.remove(downloadModel)
            DownloadManager.shared.dlContex.delete(downloadModel)
            DownloadManager.shared.saveDataRightNow()
            
            //updateUI
            self.downloadTable!.deleteRows(at: [indexPath], with: .bottom)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute:{
                self.downloadTable!.reloadData()
            })
            playDeleteSound()
        }
        
        //delete downloaded file
        if(indexPath.section == 1){
            let deleteModel = DownloadManager.shared.downloadeds![indexPath.row] as! DownloadModel
            //cache
            let realFilePath = MyDocumentsPath + "/" + (deleteModel.fileName)!
            try?FileManager.default.removeItem(atPath: realFilePath)
            //coredata remove
            DownloadManager.shared.downloadeds?.remove(deleteModel)
            DownloadManager.shared.dlContex.delete(deleteModel)
            DownloadManager.shared.saveDataRightNow()
            //updateUI
           // let indexPath = IndexPath.init(item: indexPath.row, section: indexPath.section)
            self.downloadTable!.deleteRows(at: [indexPath], with: .bottom)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute:{
                self.downloadTable!.reloadData()
            })
            playDeleteSound()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return Localized(enKey: "Delete")
    }
    
    @objc func refreshQueue() -> Void {
        self.downloadTable?.reloadData()
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
